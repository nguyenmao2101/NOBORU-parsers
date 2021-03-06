ScanFR = Parser:new("ScanFR", "https://www.scan-fr.co", "FRA", "SCANFRA")

function ScanFR:getManga(link, dest_table)
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
    local content = file.string or ""
    local t = dest_table
    local done = true
	for Link, ImageLink, Name in content:gmatch("<a href=\"([^\"]-)\" class=\"thumbnail\">[^>]-src='([^']-)' alt='([^']-)' />[^<]-</a>") do
		local manga = CreateManga(Name, Link, ImageLink, self.ID, Link)
		if manga then
			t[#t + 1] = manga
			done = false
		end
		coroutine.yield(false)
	end
	if done then
		t.NoPages = true
	end
end

function ScanFR:getPopularManga(page, dest_table)
    self:getManga(self.Link.."/filterList?sortBy=views&asc=false&page="..page, dest_table)
end

function ScanFR:searchManga(search, page, dest_table)
    self:getManga(self.Link.."/filterList?alpha="..search.."&sortBy=views&asc=false&page="..page, dest_table)
end

function ScanFR:getChapters(manga, dest_table)
	local file = {}
	Threads.insertTask(file, {
		Type = "StringRequest",
		Link = manga.Link,
		Table = file,
		Index = "string"
	})
	while Threads.check(file) do
		coroutine.yield(false)
    end
    local content = file.string or ""
    local t = {}
    for Link, Name, SubName in content:gmatch("chapter%-title%-rtlrr\">[^<]-<a href=\"([^\"]-)\">([^<]-)</a>.-<em>(.-)</em>") do
        t[#t + 1] = {
			Name = Name..":"..SubName,
			Link = Link,
			Pages = {},
			Manga = manga
		}
    end
	for i = #t, 1, -1 do
		dest_table[#dest_table + 1] = t[i]
	end
end

function ScanFR:prepareChapter(chapter, dest_table)
	local file = {}
	Threads.insertTask(file, {
		Type = "StringRequest",
		Link = chapter.Link,
		Table = file,
		Index = "string"
	})
	while Threads.check(file) do
		coroutine.yield(false)
    end
    local content = file.string or ""
	local t = dest_table
	for Link in content:gmatch("img%-responsive\"[^>]-data%-src=' ([^']-) '") do
        t[#t + 1] = Link
		Console.write("Got " .. t[#t])
    end
end

function ScanFR:loadChapterPage(link, dest_table)
	dest_table.Link = link
end
