import catppuccin

config.load_autoconfig()
config.bind('tt', 'config-cycle tabs.width 0% 18 10% 15%')
config.unbind('M', mode = 'normal')
config.unbind('m', mode = 'normal')
config.unbind('d')
config.bind('m', 'cmd-set-text :quickmark-add {{url}} {{title}}', mode = 'normal')
config.bind('M', 'quickmark-save', mode = 'normal')
config.bind('dd', 'tab-close', mode = 'normal')
config.bind('d$', 'tab-only -p', mode = 'normal')
config.bind('D', 'tab-only -p', mode = 'normal')
config.bind('d0', 'tab-only -n', mode = 'normal')
config.bind('td', 'config-cycle colors.webpage.darkmode.enabled True False')
config.bind('<Ctrl-Shift-J>', 'tab-move +', mode = 'normal')
config.bind('<Ctrl-Shift-K>', 'tab-move -', mode = 'normal')
# I found that qutebrowser already has these built-in...
# config.unbind('yy', mode = 'normal')
# config.bind('yyy', 'yank', mode = 'normal')
# config.bind('yym', 'yank inline [{title}]({url:pretty})', mode = 'normal')
config.bind('gk', 'tab-focus last', mode = 'normal')
config.unbind('f', mode = 'normal')
config.unbind('F', mode = 'normal')
config.bind('ff', 'hint all normal', mode = 'normal')
config.bind('ft', 'hint all tab', mode = 'normal')
config.bind('fh', 'hint all hover', mode = 'normal')
config.bind('fr', 'hint all right-click', mode = 'normal')
config.bind('fy', 'hint all yank', mode = 'normal')
config.unbind('<Ctrl-N>', mode = 'command')
config.unbind('<Ctrl-P>', mode = 'command')
config.bind('<Ctrl-N>', 'completion-item-focus next', mode = 'command')
config.bind('<Ctrl-P>', 'completion-item-focus prev', mode = 'command')
config.bind('eu', 'edit-url', mode = 'normal')

startFloatingFoot = '/home/spreadzhao/scripts/niri/start_floating_foot.sh'

c.content.pdfjs = True
c.downloads.location.suggestion = 'both'
c.editor.command = [
    startFloatingFoot,
    'nvim +"set wrap" {file}',
]

fileChooser = [
    startFloatingFoot,
    'lf -selection-path={}'
]
c.fileselect.folder.command = fileChooser
c.fileselect.handler = 'external'
c.fileselect.multiple_files.command = fileChooser
c.fileselect.single_file.command = fileChooser

# c.colors.tabs.bar.bg = 'black'
# c.colors.tabs.even.bg = 'black'
# c.colors.tabs.odd.bg = 'black'
#
# c.colors.tabs.selected.even.bg = '#b5b5b5'
# c.colors.tabs.selected.even.fg = 'black'
# c.colors.tabs.selected.odd.bg = '#b5b5b5'
# c.colors.tabs.selected.odd.fg = 'black'
# c.colors.tabs.pinned.selected.odd.bg = '#820030'
# c.colors.tabs.pinned.selected.even.bg = '#820030'
# c.colors.tabs.pinned.selected.odd.fg = 'white'
# c.colors.tabs.pinned.selected.even.fg = 'white'

c.colors.webpage.bg = 'black'
c.colors.webpage.preferred_color_scheme = 'dark'
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = 'never'

# c.content.headers.user_agent = {
#     'https://accounts.google.com/*':
#         'Mozilla/5.0 ({os_info}; rv:135.0) Gecko/20100101 Firefox/135'
# }

c.fonts.completion.category = 'bold default_size default_family'
c.fonts.completion.entry = 'default_size default_family'
c.fonts.contextmenu = None
c.fonts.debug_console = 'default_size default_family'
c.fonts.downloads = 'default_size default_family'
c.fonts.hints = 'bold default_size default_family'
c.fonts.keyhint = 'default_size default_family'
c.fonts.messages.error = 'default_size default_family'
c.fonts.messages.info = 'default_size default_family'
c.fonts.messages.warning = 'default_size default_family'
c.fonts.prompts = 'default_size sans-serif'
c.fonts.statusbar = 'default_size default_family'
c.fonts.tabs.selected = 'default_size default_family'
c.fonts.tabs.unselected = 'default_size default_family'
c.fonts.tooltip = None
c.fonts.web.family.cursive = ''
c.fonts.web.family.fantasy = ''
c.fonts.web.family.fixed = ''
c.fonts.web.family.sans_serif = ''
c.fonts.web.family.serif = ''
c.fonts.web.family.standard = ''
c.fonts.web.size.default = 16
c.fonts.web.size.default_fixed = 13
c.fonts.web.size.minimum = 0
c.fonts.web.size.minimum_logical = 6

c.fonts.default_family = [
    'Noto Color Emoji'
    'Symbols Nerd Font Mono'
    'IBM Plex Sans'
    'IBM Plex Sans SC'
    'IBM Plex Sans TC'
    'IBM Plex Sans JP'
    'IBM Plex Sans KR'
    'IBM Plex Sans Thai'
    'IBM Plex Sans Thai Looped'
    'IBM Plex Sans Hebrew'
    'IBM Plex Sans Arabic'
    'IBM Plex Sans Devanagari'
]
c.fonts.default_size = '12pt'

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
c.statusbar.padding = {
    'top': -0,
    'bottom': -0,
    'left': 0,
    'right': 0,
}

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
c.tabs.title.format = '{audio}{relative_index}:{current_title}'
c.tabs.title.format_pinned = '{audio}{relative_index}:{current_title}'
c.tabs.width = 18
c.tabs.favicons.show = 'always'
c.tabs.mousewheel_switching = False;
c.tabs.new_position.unrelated = 'next';

c.url.default_page = 'about:blank'
c.url.start_pages = ['about:blank']

c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}'
}

c.search.incremental = False;


c.zoom.default = '100%'
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

c.window.hide_decoration = True;

catppuccin.setup(c, 'mocha', True)
