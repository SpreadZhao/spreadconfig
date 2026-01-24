config.load_autoconfig()
config.bind('tt', 'config-cycle tabs.width 0% 27 10%')
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
config.unbind('yy', mode = 'normal')
config.bind('yyy', 'yank', mode = 'normal')
config.bind('yym', 'yank inline [{title}]({url:pretty})', mode = 'normal')
config.bind('gk', 'tab-focus last', mode = 'normal')

c.colors.tabs.bar.bg = 'black'
c.colors.tabs.even.bg = 'black'
c.colors.tabs.odd.bg = 'black'

c.colors.tabs.selected.even.bg = '#b5b5b5'
c.colors.tabs.selected.even.fg = 'black'
c.colors.tabs.selected.odd.bg = '#b5b5b5'
c.colors.tabs.selected.odd.fg = 'black'
c.colors.tabs.pinned.selected.odd.bg = '#820030'
c.colors.tabs.pinned.selected.even.bg = '#820030'
c.colors.tabs.pinned.selected.odd.fg = 'white'
c.colors.tabs.pinned.selected.even.fg = 'white'

c.colors.webpage.bg = 'black'
c.colors.webpage.preferred_color_scheme = 'dark'
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = 'never'

# c.content.headers.user_agent = {
#     'https://accounts.google.com/*':
#         'Mozilla/5.0 ({os_info}; rv:135.0) Gecko/20100101 Firefox/135'
# }

c.fonts.default_family = ['Noto Sans']
c.fonts.default_size = '16pt'

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
c.tabs.title.format = '{audio}{relative_index}:{current_title}'
c.tabs.title.format_pinned = '{audio}{relative_index}:{current_title}'
c.tabs.width = 27
c.tabs.favicons.show = 'always'
c.tabs.mousewheel_switching = False;
c.tabs.new_position.unrelated = 'next';

c.url.default_page = 'about:blank'
c.url.start_pages = ['about:blank']

c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}'
}

c.search.incremental = False;


c.zoom.default = '150%'
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

def theme_setup(c):
    palette = {
        "background": "#000000",  # gray
        "foreground": "#d4d4d4",  # white
        "black": "#000000",
        "dark-gray": "#1a1a1a",
        "gray": "#282c34",
        "cool-gray": "#3b404d",
        "medium-gray": "#3f444a",
        "light-gray": "#5b6268",
        "lighter-gray": "#73797e",
        "pale-gray": "#9ca0a4",
        "white": "#dfdfdf",
        "bright-white": "#fefefe",
        "pure-white": "#ffffff",
        "darker-purple": "#5b3766",
        "dark-purple": "#615c80",
        "purple": "#a9a1e1",
        "dark-pink": "#945aa6",
        "pink": "#c678dd",
        "dark-blue": "#2257a0",
        "blue": "#51afef",
        "light-blue": "#7bb6e2",
        "cyan": "#46d9ff",
        "dark-green": "#668044",
        "green": "#98be65",
        "teal": "#4db5bd",
        "red": "#ff6c6b",
        "orange": "#da8548",
        "yellow": "#ecbe7b",
    }

    # Background color of the completion widget category headers.
    c.colors.completion.category.bg = palette["cool-gray"]

    # Bottom border color of the completion widget category headers.
    c.colors.completion.category.border.bottom = palette["dark-gray"]

    # Top border color of the completion widget category headers.
    c.colors.completion.category.border.top = palette["dark-gray"]

    # Foreground color of completion widget category headers.
    c.colors.completion.category.fg = palette["yellow"]

    # Background color of the completion widget for even rows.
    c.colors.completion.even.bg = palette["background"]

    # Background color of the completion widget for odd rows.
    c.colors.completion.odd.bg = palette["dark-gray"]

    # Text color of the completion widget.
    c.colors.completion.fg = palette["foreground"]

    # Background color of the selected completion item.
    c.colors.completion.item.selected.bg = palette["medium-gray"]

    # Bottom border color of the selected completion item.
    c.colors.completion.item.selected.border.bottom = palette["medium-gray"]

    # Top border color of the completion widget category headers.
    c.colors.completion.item.selected.border.top = palette["medium-gray"]

    # Foreground color of the selected completion item.
    c.colors.completion.item.selected.fg = palette["foreground"]

    # Foreground color of the matched text in the completion.
    c.colors.completion.match.fg = palette["pink"]

    # Foreground color of the selected matched text in the completion.
    c.colors.completion.item.selected.match.fg = palette["light-blue"]

    # Color of the scrollbar in completion view
    c.colors.completion.scrollbar.bg = palette["medium-gray"]

    # Color of the scrollbar handle in completion view.
    c.colors.completion.scrollbar.fg = palette["light-gray"]

    # Background color for the download bar.
    c.colors.downloads.bar.bg = palette["dark-gray"]

    # Background color for downloads with errors.
    c.colors.downloads.error.bg = palette["red"]

    # Foreground color for downloads with errors.
    c.colors.downloads.error.fg = palette["pure-white"]

    # Color gradient start for download grays.
    c.colors.downloads.start.bg = palette["blue"]

    # Color gradient stop for download grays.
    c.colors.downloads.stop.bg = palette["dark-green"]

    # Color gradient start for download foregrounds.
    c.colors.downloads.start.fg = palette["pure-white"]

    # Color gradient stop for download foregrounds.
    c.colors.downloads.stop.fg = palette["pure-white"]

    # Color gradient interpolation system for download backgrounds.
    # Valid values:
    #   - rgb: Interpolate in the RGB color system.
    #   - hsv: Interpolate in the HSV color system.
    #   - hsl: Interpolate in the HSL color system.
    #   - none: Don't show a gradient.
    c.colors.downloads.system.bg = "rgb"

    # Color gradient interpolation system for download foregrounds.
    c.colors.downloads.system.fg = "rgb"

    # Background color for hints. Note that you can use a `rgba(...)` value
    # for transparency.
    c.colors.hints.bg = palette["black"]

    # Font color for hints.
    c.colors.hints.fg = palette["foreground"]

    c.hints.border = "1px solid " + palette["dark-gray"]

    # Font color for the matched part of hints.
    c.colors.hints.match.fg = palette["dark-green"]

    # Background color of the keyhint widget.
    c.colors.keyhint.bg = palette["dark-gray"]

    # Text color for the keyhint widget.
    c.colors.keyhint.fg = palette["blue"]

    # Highlight color for keys to complete the current keychain.
    c.colors.keyhint.suffix.fg = palette["green"]

    # Background color of an error message.
    c.colors.messages.error.bg = palette["dark-gray"]

    # Border color of an error message.
    c.colors.messages.error.border = palette["light-gray"]

    # Foreground color of an error message.
    c.colors.messages.error.fg = palette["red"]

    # Background color of an info message.
    c.colors.messages.info.bg = palette["background"]

    # Border color of an info message.
    c.colors.messages.info.border = palette["light-gray"]

    # Foreground color an info message.
    c.colors.messages.info.fg = palette["foreground"]

    # Background color of a warning message.
    c.colors.messages.warning.bg = palette["background"]

    # Border color of a warning message.
    c.colors.messages.warning.border = palette["light-gray"]

    # Foreground color a warning message.
    c.colors.messages.warning.fg = palette["red"]

    # Background color for prompts.
    c.colors.prompts.bg = palette["background"]

    # Border used around UI elements in prompts.
    c.colors.prompts.border = "1px solid " + palette["light-gray"]

    # Foreground color for prompts.
    c.colors.prompts.fg = palette["foreground"]

    # Background color for the selected item in filename prompts.
    c.colors.prompts.selected.bg = palette["light-gray"]

    # Background color of the statusbar in caret mode.
    c.colors.statusbar.caret.bg = palette["dark-purple"]

    # Foreground color of the statusbar in caret mode.
    c.colors.statusbar.caret.fg = palette["foreground"]

    # Background color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.bg = palette["dark-pink"]

    # Foreground color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.fg = palette["foreground"]

theme_setup(c)
