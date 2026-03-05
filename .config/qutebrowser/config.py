import json, os

with open(os.path.expanduser("~/.cache/wal/colors.json")) as f:
    wal = json.load(f)

bg       = wal["special"]["background"]
fg       = wal["special"]["foreground"]
cursor   = wal["special"]["cursor"]
c0  = wal["colors"]["color0"]
c1  = wal["colors"]["color1"]
c2  = wal["colors"]["color2"]
c3  = wal["colors"]["color3"]
c4  = wal["colors"]["color4"]
c5  = wal["colors"]["color5"]
c6  = wal["colors"]["color6"]
c7  = wal["colors"]["color7"]
c8  = wal["colors"]["color8"]


config.load_autoconfig(False)

# Completion (выпадающее меню адресной строки)
c.colors.completion.fg                     = fg
c.colors.completion.odd.bg                 = bg
c.colors.completion.even.bg                = c0
c.colors.completion.category.fg            = c3
c.colors.completion.category.bg            = bg
c.colors.completion.item.selected.fg       = fg
c.colors.completion.item.selected.bg       = c8
c.colors.completion.match.fg               = c2

# Statusbar
c.colors.statusbar.normal.bg               = bg
c.colors.statusbar.normal.fg               = fg
c.colors.statusbar.insert.bg               = c2
c.colors.statusbar.insert.fg               = bg
c.colors.statusbar.url.fg                  = fg
c.colors.statusbar.url.success.https.fg    = c2
c.colors.statusbar.url.error.fg            = c1
c.colors.statusbar.url.warn.fg             = c3

# Tabs
c.colors.tabs.bar.bg                       = bg
c.colors.tabs.odd.bg                       = bg
c.colors.tabs.odd.fg                       = c8
c.colors.tabs.even.bg                      = bg
c.colors.tabs.even.fg                      = c8
c.colors.tabs.selected.odd.bg              = c8
c.colors.tabs.selected.odd.fg              = fg
c.colors.tabs.selected.even.bg             = c8
c.colors.tabs.selected.even.fg             = fg

# Hints (буквы для hint-mode)
c.colors.hints.bg                          = c3
c.colors.hints.fg                          = bg
c.colors.hints.match.fg                    = c1

# Прочее
c.colors.keyhint.bg                        = bg
c.colors.keyhint.fg                        = fg
c.colors.messages.error.bg                 = c1
c.colors.messages.error.fg                 = bg
c.colors.messages.warning.bg               = c3
c.colors.messages.warning.fg               = bg
c.colors.webpage.bg                        = bg

# Говорит сайтам «я хочу тёмный режим» через CSS prefers-color-scheme
c.colors.webpage.preferred_color_scheme = "dark"

# Принудительно инвертирует страницы, у которых нет своего dark mode
c.colors.webpage.darkmode.enabled = True

# Алгоритм инверсии — lightness работает лучше всего для текста
c.colors.webpage.darkmode.algorithm = "lightness-cielab"

# Не трогать изображения (иначе фото выглядят жутко)
c.colors.webpage.darkmode.policy.images = "never"
c.aliases["darkmode"] = "config-cycle colors.webpage.darkmode.enabled True False"

# Открыть текущую страницу в mpv
config.bind('M', 'hint links spawn mpv-yt {hint-url}')
config.bind('Z', 'spawn mpv-yt {url}')


# Поисковые страницы
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "g":  "https://www.google.com/search?q={}",
    "yt": "https://www.youtube.com/results?search_query={}",
    "gh": "https://github.com/search?q={}",
    "aw": "https://wiki.archlinux.org/?search={}",
    "wp": "https://en.wikipedia.org/w/index.php?search={}",
    "rt": "https://rutracker.org/forum/tracker.php?nm={}",
}
c.url.start_pages  = ["about:blank"]
c.url.default_page = "about:blank"

# Блокировщик
c.content.blocking.enabled = True
c.content.blocking.method  = "adblock"   # или "both"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
]

# Внешний редактор и загрузки
c.editor.command = ["alacritty", "-e", "nvim", "{}"]
c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt    = True
c.downloads.open_dispatcher    = "xdg-open"

# Приватность
c.content.autoplay                = False
c.content.notifications.enabled  = False
c.content.geolocation             = False
c.content.headers.do_not_track   = True
c.content.webgl                  = False

# Перезагрузить конфиг без перезапуска
config.bind('<Ctrl-r>', 'config-source')

# Открыть конфиг в редакторе
config.bind(',e', 'config-edit')

# Сохранить сессию
config.bind(',s', 'session-save')

# Пинить вкладку
config.bind(',p', 'tab-pin')

# Буфер обмена → открыть URL
config.bind('p',  'open -- {clipboard}')
config.bind('P',  'open -t -- {clipboard}')

# Шрифты 
c.fonts.default_family = "JetBrainsMono Nerd Font"  # или твой моноширинный
c.fonts.default_size   = "12pt"
c.fonts.completion.entry  = "12pt default_family"
c.fonts.statusbar         = "12pt default_family"
c.tabs.title.format       = "{audio}{index}: {current_title}"
c.tabs.show               = "multiple"    # скрывать таббар при одной вкладке
c.zoom.default            = "100%"

c.auto_save.session = True

config.unbind('.')
en_keys = "qwertyuiop[]asdfghjkl;'zxcvbnm,./"+'QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?'
ru_keys = 'йцукенгшщзхъфывапролджэячсмитьбю.'+'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,'
for key in ru_keys:
    c.bindings.key_mappings[key]=en_keys[ru_keys.index(key)]
