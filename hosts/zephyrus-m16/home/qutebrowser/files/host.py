# Keep GPU compositing for video overlays, but decode video in software.
# QtWebEngine 6.11 imports Intel VA-API frames through NVIDIA and aborts with
# "dma_buf acquisition failure". Compositing still runs on the Intel GPU.
c.qt.args = [
    'ignore-gpu-blocklist',
    'enable-gpu-rasterization',
    'enable-zero-copy',
    'disable-accelerated-video-decode',
]
c.qt.workarounds.disable_accelerated_2d_canvas = 'never'
c.content.webgl = True

c.fonts.web.size.default = 12
c.fonts.web.size.default_fixed = 9
c.fonts.web.size.minimum_logical = 2
c.fonts.default_size = '8pt'
c.zoom.default = '70%'
