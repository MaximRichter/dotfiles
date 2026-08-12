local mp = require("mp")
local utils = require("mp.utils")

-- How deeply to search below the video's directory.
local MAX_DEPTH = 3

local subtitle_extensions = {
    ass = true,
    ssa = true,
    srt = true,
}

local function basename(path)
    local _, name = utils.split_path(path)
    return name
end

-- Returns season (when explicitly present) and episode.
-- Supported examples: S01E03, [03], " 03 [metadata]", " - 03 ".
local function episode_from_name(name)
    local lower = name:lower()

    local season, episode = lower:match("s(%d+)[%s._%-]*e(%d+)")
    if episode then
        return tonumber(season), tonumber(episode)
    end

    episode = name:match("%[(%d%d?)%]")
    if episode then
        return nil, tonumber(episode)
    end

    episode = name:match("[%s._%-](%d%d?)[%s._%-]*%[")
    if episode then
        return nil, tonumber(episode)
    end

    episode = name:match("[%s._%-](%d%d?)[%s._%-]")
    if episode then
        return nil, tonumber(episode)
    end

    return nil, nil
end

local function is_subtitle(name)
    local extension = name:lower():match("%.([^.]+)$")
    return extension and subtitle_extensions[extension] or false
end

local function collect(directory, wanted_season, wanted_episode, depth, results)
    if depth > MAX_DEPTH then
        return
    end

    for _, name in ipairs(utils.readdir(directory, "files") or {}) do
        if is_subtitle(name) then
            local season, episode = episode_from_name(name)
            local season_matches = not wanted_season or not season or season == wanted_season

            if episode == wanted_episode and season_matches then
                table.insert(results, utils.join_path(directory, name))
            end
        end
    end

    for _, name in ipairs(utils.readdir(directory, "dirs") or {}) do
        collect(
            utils.join_path(directory, name),
            wanted_season,
            wanted_episode,
            depth + 1,
            results
        )
    end
end

local function loaded_external_subtitles()
    local loaded = {}

    for _, track in ipairs(mp.get_property_native("track-list") or {}) do
        if track.type == "sub" and track["external-filename"] then
            loaded[basename(track["external-filename"])] = true
        end
    end

    return loaded
end

local function load_episode_subtitles()
    local video_path = mp.get_property("path")
    if not video_path or video_path:match("^%a[%w+.-]*://") then
        return
    end

    local directory, video_name = utils.split_path(video_path)
    local season, episode = episode_from_name(video_name)

    if not episode then
        mp.msg.verbose("episode-subs: no episode number in " .. video_name)
        return
    end

    if directory == "" then
        directory = "."
    end

    local matches = {}
    collect(directory, season, episode, 0, matches)
    table.sort(matches)

    local loaded = loaded_external_subtitles()
    local added = 0

    for _, path in ipairs(matches) do
        if not loaded[basename(path)] then
            -- "auto" adds the track without forcibly selecting each successive file.
            mp.commandv("sub-add", path, "auto")
            mp.msg.info("episode-subs: added " .. path)
            added = added + 1
        end
    end

    mp.msg.info(string.format(
        "episode-subs: episode %d, found %d, added %d",
        episode,
        #matches,
        added
    ))
end

mp.register_event("file-loaded", load_episode_subtitles)
