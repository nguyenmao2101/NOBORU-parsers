NineHentai = Parser:new("NineHentai", "https://9hentai.com", "DIF", 5)

NineHentai.NSFW = true

NineHentai.query = [[
	{
		"search":{
			"text":"%s",
			"page":%s,
			"sort":%s,
			"pages":{
				"range":[0,100000]
			},
			"tag":{
				"text":"",
				"type":1,
				"tags":[],
				"items":{
					"included":[],
					"excluded":[]
				}
			}
		}
	}
]]

function NineHentai:getManga(mode, page, dest_table, search)
	local file = {}
	if mode == 0 then
		Threads.DownloadStringAsync(self.Link .. "/api/getBook", file, "string", true, POST_METHOD, string.format(self.query, "", page - 1, 0), JSON)
	elseif mode == 1 then
		Threads.DownloadStringAsync(self.Link .. "/api/getBook", file, "string", true, POST_METHOD, string.format(self.query, "", page - 1, 1), JSON)
	elseif mode == 2 then
		Threads.DownloadStringAsync(self.Link .. "/api/getBook", file, "string", true, POST_METHOD, string.format(self.query, search:gsub("%%", "%*"), page - 1, 0), JSON)
	end
	while file.string == nil do
		coroutine.yield(false)
	end
	local t = dest_table
	local done = true
	for id, title, count, link in file.string:gmatch('"id":(%d-),"title":"(.-)",.-"total_page":(.-),.-"image_server":"(.-)"') do
		local server = link:gsub("\\/", "/") .. id .. "/"
		local manga = CreateManga(title, id, server .. "cover-small.jpg", self.ID, self.Link .. "/g/" .. id)
		if manga then
			manga.Count = count
			manga.NineHentaiServer = server
			t[#t + 1] = manga
			done = false
		end
		coroutine.yield(false)
	end
	if done then
		t.NoPages = true
	end
end

function NineHentai:getLatestManga(page, dest_table)
	self:getManga(0, page, dest_table)
end

function NineHentai:getPopularManga(page, dest_table)
	self:getManga(1, page, dest_table)
end

function NineHentai:searchManga(search, page, dest_table)
	self:getManga(2, page, dest_table, search)
end

function NineHentai:getChapters(manga, dest_table)
	dest_table[#dest_table + 1] = {
		Name = manga.Name,
		Link = manga.Link,
		Pages = {},
		Manga = manga
	}
end

function NineHentai:prepareChapter(chapter, dest_table)
	local t = dest_table
	for i = 1, chapter.Manga.Count do
		t[i] = chapter.Manga.NineHentaiServer .. i .. ".jpg"
		Console.write("Got " .. t[i])
	end
end

function NineHentai:loadChapterPage(link, dest_table)
	dest_table.Link = link
end
