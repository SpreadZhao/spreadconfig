config.load_autoconfig()
config.bind('tt', 'config-cycle tabs.show always never')
# config.unbind('d', mode = 'normal')
c.aliases.update({
    'q': 'close',
    'qa': 'quit',
    'w': 'session-save',
    'wq': 'quit --save',
    'wqa': 'quit --save',
})
c.auto_save.session = True
config.bind('<Ctrl-6>', '<Ctrl-^>')
config.bind('<Ctrl-Enter>', '<Ctrl-Return>')
config.bind('<Ctrl-I>', '<Tab>')
config.bind('<Ctrl-J>', '<Return>')
config.bind('<Ctrl-M>', '<Return>')
config.bind('<Ctrl-[>', '<Escape>')
config.bind('<Enter>', '<Return>')
config.bind('<Shift-Enter>', '<Return>')
config.bind('<Shift-Return>', '<Return>')

c.colors.tabs.bar.bg = 'black'
c.colors.tabs.even.bg = 'black'
c.colors.tabs.odd.bg = 'black'

c.colors.tabs.selected.even.bg = '#b5b5b5'
c.colors.tabs.selected.even.fg = 'black'
c.colors.tabs.selected.odd.bg = '#b5b5b5'
c.colors.tabs.selected.odd.fg = 'black'
c.colors.tabs.pinned.selected.odd.bg = '#b5b5b5'
c.colors.tabs.pinned.selected.even.bg = '#b5b5b5'
c.colors.tabs.pinned.selected.odd.fg = 'black'
c.colors.tabs.pinned.selected.even.fg = 'black'

c.colors.webpage.preferred_color_scheme = 'dark'

# c.content.headers.user_agent = {
#     'https://accounts.google.com/*':
#         'Mozilla/5.0 ({os_info}; rv:135.0) Gecko/20100101 Firefox/135'
# }

c.fonts.default_family = ['Noto Sans']
c.fonts.default_size = '16pt'

c.hints.next_regexes = [
    r'\bnext\b',
    r'\bmore\b',
    r'\bnewer\b',
    r'\b[>→≫]\b',
    r'\b(>>|»)\b',
    r'\bcontinue\b',
]

c.statusbar.position = 'top'
c.statusbar.widgets = [
    'keypress',
    'search_match',
    'url',
    'scroll',
    'history',
    'tabs',
    'progress',
]

c.tabs.indicator.padding = {
    'top': 2,
    'bottom': 2,
    'left': 0,
    'right': 0,
}
c.tabs.indicator.width = 0

c.tabs.padding = {
    'top': 0,
    'bottom': 0,
    'left': 0,
    'right': 0,
}

c.tabs.position = 'left'
c.tabs.select_on_remove = 'last-used'
c.tabs.show = 'always'
c.tabs.title.format = '{audio}{index}:{current_title}'
c.tabs.title.format_pinned = '{audio}{index}:{current_title}'
c.tabs.width = '10%'

c.url.default_page = 'about:blank'
c.url.start_pages = ['about:blank']

c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}'
}


c.zoom.default = '130%'
c.zoom.levels = [
    '25%',
    '33%',
    '50%',
    '67%',
    '75%',
    '90%',
    '100%',
    '110%',
    '125%',
    '130%',
    '150%',
    '175%',
    '200%',
    '250%',
    '300%',
    '400%',
    '500%',
]
c.zoom.mouse_divider = 0
