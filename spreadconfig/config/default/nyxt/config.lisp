(in-package #:nyxt-user)

(define-configuration browser
  ((default-new-buffer-url (quri:uri "about:blank"))
   (external-editor-program
    '("footclient" "-a" "lick-foot" "--" "nvim" "+set wrap"))
   (search-engines
    (list
     (make-instance 'search-engine
                    :name "Google"
                    :shortcut "google"
                    :control-url "https://www.google.com/search?q=~a")))
   (theme theme:+dark-theme+)))

(define-configuration nyxt/mode/history:history-mode
  ((history-blocklist '("http://" "https://"))))

(define-configuration document-buffer
  ((zoom-ratio-default 1.0)))

;; Match qutebrowser's modal interaction while keeping prompts ready for input.
(define-configuration input-buffer
  ((default-modes
    (pushnew 'nyxt/mode/vi:vi-normal-mode %slot-value%))))

(define-configuration prompt-buffer
  ((default-modes
    (pushnew 'nyxt/mode/vi:vi-insert-mode %slot-value%))))

(defvar *qutebrowser-keymap*
  (keymaps:make-keymap "qutebrowser-like"))

(define-key *qutebrowser-keymap*
  "g j" 'switch-buffer-next
  "g k" 'switch-buffer-previous
  "d d" 'delete-current-buffer
  "d a" 'delete-other-buffers
  "D" 'delete-other-buffers
  "e u" 'set-url
  "t d" 'nyxt/mode/style:dark-mode
  "t t" 'toggle-status-buffer
  "f f" 'nyxt/mode/hint:follow-hint
  "f t" 'nyxt/mode/hint:follow-hint-new-buffer
  "f y" 'nyxt/mode/hint:copy-hint-url
  "m" 'nyxt/mode/bookmark:add-bookmark
  "M" 'nyxt/mode/bookmark:set-url-from-bookmark
  "y y" 'copy-url
  "y t" 'copy-title)

(define-mode qutebrowser-mode ()
  "Qutebrowser-like bindings for Nyxt web buffers."
  ((keyscheme-map
    (keymaps:make-keyscheme-map
     nyxt/keyscheme:vi-normal *qutebrowser-keymap*))))

(define-configuration web-buffer
  ((default-modes
    (pushnew 'qutebrowser-mode %slot-value%))))

(define-configuration nyxt/mode/prompt-buffer:prompt-buffer-mode
  ((keyscheme-map
    (define-keyscheme-map
     "qutebrowser-prompt" (list :import %slot-value%)
     nyxt/keyscheme:vi-normal
     (list
      "C-n" 'nyxt/mode/prompt-buffer:next-suggestion
      "C-p" 'nyxt/mode/prompt-buffer:previous-suggestion
      "C-d" 'nyxt/mode/prompt-buffer:next-source
      "C-u" 'nyxt/mode/prompt-buffer:previous-source)
     nyxt/keyscheme:vi-insert
     (list
      "C-n" 'nyxt/mode/prompt-buffer:next-suggestion
      "C-p" 'nyxt/mode/prompt-buffer:previous-suggestion
      "C-d" 'nyxt/mode/prompt-buffer:next-source
      "C-u" 'nyxt/mode/prompt-buffer:previous-source)))))
