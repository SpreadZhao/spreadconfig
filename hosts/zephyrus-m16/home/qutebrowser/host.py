# Keep QtWebEngine on the GPU path for video overlays such as live danmaku.
# Software video decode: QtWebEngine 6.11's SurfaceFactoryQt imports decoded
# video dmabufs via a GBM device on the NVIDIA node, which cannot import Intel
# VA-API frames (qFatal "dma_buf acquisition failure"). Compositing still runs
# on the iGPU.
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
