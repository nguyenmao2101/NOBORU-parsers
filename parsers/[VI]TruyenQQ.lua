TruyenQQ = Parser:new("TruyenQQ", "http://truyenqq.com", "VIE", "TruyenQQVIE")

local function downloadContent(link)
    local file = {}
    Threads.insertTask(file, {
        Type = "StringRequest",
        Link = link,
        Table = file,
        Index = "string"
    })
    while Threads.check(file) do
        coroutine.yield(false)
    end
    return file.string or ""
end

function TruyenQQ:getManga(link, page, dest_table)
    local content = downloadContent(link)
    local t = dest_table
    local done = true
    for Link, ImageLink, Name in content:gmatch('item">[^<]-<a.-href="([^"]-)".->.-<img[^>]-src="([^"]-)".-alt="([^"]-)"') do
        -- Console.write("found: ".. Name .. " : " .. Link .. " : " .. ImageLink)
        -- if not ImageLink then
        --     ImageLink = "https://raw.githubusercontent.com/nguyenmao2101/NOBORU-parsers/master/default_img/truyenqq.png"
        -- end
        -- ImageLink = "https://raw.githubusercontent.com/nguyenmao2101/NOBORU-parsers/master/default_img/truyenqq.png"
        local manga = CreateManga(Name, Link, ImageLink, self.Id, Link)
        if manga then
            Console.write("manga created")
			t[#t + 1] = manga
			done = false
		end
        coroutine.yield(false)
        if done then
            t.NoPages = true
        end
    end
end

function TruyenQQ:getPopularManga(page, dest_table)
    self:getManga(self.Link .. "/truyen-yeu-thich/trang-" .. page .. ".html", dest_table)
end

function TruyenQQ:getLatestManga(page, dest_table)
    self:getManga(self.Link .. "/truyen-moi-cap-nhat/trang-" .. page .. ".html", dest_table)
end

function TruyenQQ:searchManga(search, page, dest_table)
    self:getManga(self.Link .. "/tim-kiem/trang-" ..page.. ".html?q=" .. search, dest_table)
end

function TruyenQQ:getChapters(manga, dest_table)
	local content = downloadContent(manga.Link)
    local t = {}
    for Link, Name in content:gmatch('item row">.-<a.-href="([^"]-)">([^>]-)</a>') do
        t[#t + 1] = {
			Name = Name:gsub("%s+", ""),
			Link = Link,
			Pages = {},
			Manga = manga
		}
    end
	for i = #t, 1, -1 do
		dest_table[#dest_table + 1] = t[i]
	end
end

function TruyenQQ:prepareChapter(chapter, dest_table)
    local content = downloadContent(chapter.Link)
	local t = dest_table
	for Link in content:gmatch('<img class="lazy".-src="([^"]-)"') do
        t[#t + 1] = Link
		Console.write("Got " .. t[#t])
    end
end

function TruyenQQ:loadChapterPage(link, dest_table)
	dest_table.Link = link
end