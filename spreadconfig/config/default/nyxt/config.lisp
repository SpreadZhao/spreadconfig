(in-package #:nyxt-user)

(nyxt:use-nyxt-package-nicknames)

(define-configuration browser
  ((theme theme:+dark-theme+)))

(defparameter *qutebrowser-vi-mode-enabled-p* nil
  "Whether to enable Vi mode and qutebrowser-style web-buffer bindings.")

(define-command edit-current-url-with-external-editor ()
  "Edit the current URL in a floating Neovim, then load the result."
  (let ((buffer (current-buffer)))
    (run-thread "edit current URL"
      (handler-case
          (uiop:with-temporary-file
              (:directory
               (files:expand (make-instance 'nyxt-temporary-directory))
               :pathname path)
            (let ((original-url (render-url (url buffer))))
              (str:to-file path original-url :if-exists :supersede)
              (uiop:run-program
               (list "footclient"
                     "-a"
                     "lick-foot"
                     "-T"
                     "Edit Nyxt URL"
                     "--"
                     "nvim"
                     "+set wrap"
                     (uiop:native-namestring path)))
              (let ((edited-url
                      (str:trim (uiop:read-file-string path))))
                (cond
                  ((not (find buffer (buffer-list)))
                   (echo-warning
                    "The original buffer was closed; edited URL was not loaded."))
                  ((str:blank? edited-url)
                   (echo-warning "Edited URL is empty; keeping the current page."))
                  ((string= edited-url original-url)
                   (echo "URL unchanged."))
                  (t
                   (ffi-buffer-load
                    buffer
                    (url (make-instance 'url-or-query :data edited-url))))))))
        (error (condition)
          (echo-warning "Failed to edit URL: ~a" condition))))))

(define-command delete-other-buffers-with-confirmation ()
  "Delete every buffer except the current one after confirmation."
  (let* ((buffer (current-buffer))
         (other-buffer-count
           (count-if-not (lambda (candidate) (eq candidate buffer))
                         (buffer-list))))
    (if (zerop other-buffer-count)
        (echo "There are no other buffers to delete.")
        (if-confirm
            ((format nil "Delete the other ~d buffer~:p?" other-buffer-count)
             :yes "delete"
             :no "cancel")
          (delete-other-buffers buffer)
          (echo "Buffer deletion canceled.")))))

(define-command set-url-from-bookmark-new-buffer ()
  "Select bookmarks and open them in new buffers, focusing the first one."
  (prompt
   :prompt "Open bookmark(s) in new buffer(s)"
   :sources
   (make-instance
    'nyxt/mode/bookmark:bookmark-source
    :actions-on-return
    (lambda-command open-bookmarks-in-new-buffers (bookmark-entries)
      (when bookmark-entries
        (dolist (entry (rest bookmark-entries))
          (make-buffer :url (url entry)))
        (make-buffer-focus :url (url (first bookmark-entries))))))))

(define-mode default-web-keybindings-mode ()
  "Custom bindings for web buffers using the default CUA keyscheme."
  ((visible-in-status-p nil)
   (keyscheme-map
    (define-keyscheme-map "default-web-bindings" ()
      nyxt/keyscheme:cua
      (list
       "C-;" 'execute-command
       "C-space" 'nothing)))))

(define-mode qutebrowser-keybindings-mode ()
  "Qutebrowser-compatible bindings with reliable Nyxt equivalents."
  ((visible-in-status-p nil)
   (keyscheme-map
    (define-keyscheme-map "qutebrowser-bindings" ()
      nyxt/keyscheme:vi-normal
      (list
       "b" 'nyxt/mode/bookmark:set-url-from-bookmark
       "B" 'set-url-from-bookmark-new-buffer
       "m" 'nyxt/mode/bookmark:add-bookmark
       "M" 'nyxt/mode/bookmark:add-bookmark
       "d d" 'delete-current-buffer
       "d a" 'delete-other-buffers-with-confirmation
       "f f" 'nyxt/mode/hint:follow-hint
       "f t" 'nyxt/mode/hint:follow-hint-new-buffer-focus
       "f y" 'nyxt/mode/hint:copy-hint-url
       "e u" 'edit-current-url-with-external-editor
       "C-6" 'switch-buffer-last
       "D" 'nothing
       "d $" 'nothing
       "d 0" 'nothing
       "d j" 'nothing
       "d k" 'nothing
       "g j" 'nothing
       "g k" 'nothing
       "C-J" 'nothing
       "C-K" 'nothing
       "F" 'nothing
       "f h" 'nothing
       "f r" 'nothing
       "t t" 'nothing
       "t d" 'nothing
       "t r" 'nothing)))))

(defmethod default-modes :around ((buffer web-buffer))
  "Give custom web bindings priority over built-in modes."
  (let* ((default-keybinding-modes '(default-web-keybindings-mode))
         (vi-modes '(qutebrowser-keybindings-mode
                     nyxt/mode/vi:vi-normal-mode))
         (custom-modes (append default-keybinding-modes vi-modes))
         (default-web-modes
           (remove-if (lambda (mode) (member mode custom-modes))
                      (call-next-method))))
    (append default-keybinding-modes
            (when *qutebrowser-vi-mode-enabled-p* vi-modes)
            default-web-modes)))

(define-mode qutebrowser-prompt-keybindings-mode ()
  "Qutebrowser-compatible bindings for CUA prompt buffers."
  ((visible-in-status-p nil)
   (keyscheme-map
    (define-keyscheme-map "qutebrowser-prompt-bindings" ()
      nyxt/keyscheme:cua
      (list
       "C-n" 'nyxt/mode/prompt-buffer:next-suggestion
       "C-p" 'nyxt/mode/prompt-buffer:previous-suggestion
       "C-d" 'nyxt/mode/prompt-buffer:next-source
       "C-u" 'nyxt/mode/prompt-buffer:previous-source
       "C-k" 'nothing
       "C-j" 'nothing)))))

(define-configuration prompt-buffer
  ((default-modes
    (cons 'qutebrowser-prompt-keybindings-mode %slot-value%))))

(defmethod format-status-tabs ((status status-buffer))
  "Render buffer tabs using page titles instead of domains."
  (let* ((buffers (reverse (buffer-list)))
         (current-buffer (active-buffer (window status))))
    (spinneret:with-html
      (loop for buffer in buffers
            collect
            (let* ((buffer buffer)
                   (url (url buffer))
                   (page-title (title buffer))
                   (domain (quri:uri-domain url))
                   (tab-display-text
                     (cond
                       ((internal-url-p url)
                        (format nil "~a:~a"
                                (quri:uri-scheme url)
                                (quri:uri-path url)))
                       ((and (stringp page-title)
                             (plusp (length page-title)))
                        page-title)
                       (t (or domain (render-url url))))))
              (:span
               :class (if (eq current-buffer buffer)
                          "selected-tab tab"
                          "tab")
               :title (render-url url)
               :onclick (ps:ps
                          (nyxt/ps:lisp-eval
                           (:title "select-tab" :buffer status)
                           (set-current-buffer buffer)))
               tab-display-text))))))

(defmethod nyxt::on-signal-notify-title :after ((buffer buffer) title)
  "Refresh tabs when a page changes its title dynamically."
  (declare (ignore buffer title))
  (dolist (window (window-list))
    (nyxt::update-status-tabs (status-buffer window))))

(defparameter *history-entry-limit* 5000)
(defparameter *history-list-default-limit* 500)

(defun make-adjustable-history-vector (entries)
  (make-array (length entries)
              :fill-pointer t
              :adjustable t
              :initial-contents entries))

(defun persist-current-history (browser)
  (files:with-file-content (history (history-file browser))
    (setf history (history-vector browser))))

(defun replace-history-entries (browser entries &key (persist-p t))
  "Replace BROWSER history in memory and, by default, on disk."
  (let ((old-history (history-vector browser))
        (new-history (make-adjustable-history-vector entries)))
    (setf (history-vector browser) new-history)
    (handler-case
        (progn
          (when persist-p
            (persist-current-history browser))
          new-history)
      (error (condition)
        (setf (history-vector browser) old-history)
        (when persist-p
          (ignore-errors (persist-current-history browser)))
        (error condition)))))

(defun trim-history-entries (browser limit &key (persist-p t))
  "Keep only the most recent LIMIT history entries in BROWSER."
  (let* ((entries (history-vector browser))
         (entry-count (length entries)))
    (when (> entry-count limit)
      (replace-history-entries
       browser
       (subseq entries (- entry-count limit))
       :persist-p persist-p))))

(defun trim-history-on-startup (browser)
  (trim-history-entries browser *history-entry-limit*))

(define-configuration nyxt/mode/history:history-mode
  ((nyxt/mode/history:history-blocklist
    '("about:" "nyxt:"))))

(define-configuration browser
  ((after-startup-hook
    (hooks:add-hook %slot-value% 'trim-history-on-startup))))

(defmethod nyxt:on-signal-load-finished :around
    ((mode nyxt/mode/history:history-mode) url title)
  "Keep memory and disk in sync while enforcing the history limit."
  (declare (ignore title))
  (if (nyxt/mode/history:blocked-p url mode)
      (call-next-method)
      (let ((history-snapshot
              (make-adjustable-history-vector (history-vector *browser*))))
        (trim-history-entries
         *browser*
         (1- *history-entry-limit*)
         :persist-p nil)
        (handler-case
            (call-next-method)
          (error (condition)
            (setf (history-vector *browser*) history-snapshot)
            (ignore-errors (persist-current-history *browser*))
            (error condition))))))

(defmethod nyxt/mode/history:list-history :around
    (&key (limit *history-list-default-limit*) %buffer%)
  (call-next-method :limit limit :%buffer% %buffer%))

(define-command-global clear-history ()
  "Delete all persisted browsing history after confirmation."
  (let ((entry-count (length (history-vector *browser*))))
    (if (zerop entry-count)
        (echo "Browsing history is already empty.")
        (if-confirm
            ((format nil "Delete all ~d browsing history entries?" entry-count)
             :yes "delete all"
             :no "cancel")
          (handler-case
              (progn
                (replace-history-entries *browser* '())
                (echo "Deleted all ~d browsing history entries." entry-count))
            (error (condition)
              (echo-warning "Failed to clear browsing history: ~a" condition)))
          (echo "Browsing history deletion canceled.")))))
