;;; persp-tab-mode.el --- add tab line with persp names  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  南優也

;; Author: 南優也 <yuyaminami@minamiyuuya-no-MacBook.local>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'persp-mode)

(define-minor-mode persp-tab-mode
  "show persp-names as `header-line-format'")

(defcustom persp-tab-separator " | "
  "Separator for persp-name."
  :group 'persp-tab)

(defface persp-tab-header-line-face
  '((t (:height 1.2 :weight bold)))
  "Used to header line"
  :group 'persp-tab)

(defun persp-tab-ignore-bufferp (bufname)
  (or (string-prefix-p " " bufname)
      (and (not (string= bufname "*GNU Emacs*"))
           (string-prefix-p "*" bufname))))

(defun persp-tab-name-formatter (persp-name current-persp-name)
  (if (string= persp-name current-persp-name)
      (format "*%s*" persp-name)
    persp-name))

(defun persp-tab-format-for-header-line ()
  (let ((perspectives (persp-names))
        (current (safe-persp-name (get-frame-persp))))
    (propertize
     (mapconcat #'(lambda (persp) (persp-tab-name-formatter persp current))
                perspectives
                persp-tab-separator)
     'face 'persp-tab-header-line-face)))

(defun persp-tab-update-header-line ()
  (let ((bufname (buffer-name)))
    (when (and bufname (not (persp-tab-ignore-bufferp bufname)))
      (if (eq 0 (window-top-line (get-buffer-window (current-buffer))))
          (setq header-line-format (persp-tab-format-for-header-line))
        (setq header-line-format nil)))))

(defun persp-tab-update-all-header-line ()
  (when persp-mode
    (with-persp-buffer-list
     ()
     (dolist (buffer (buffer-list))
       (with-current-buffer buffer
         (persp-tab-update-header-line)))))
  (remove-hook 'post-command-hook 'persp-tab-update-all-header-line))

(defun persp-enable-update-header-line (&rest args)
  (add-hook 'post-command-hook 'persp-tab-update-all-header-line))

;;;###autoload
(defun persp-tab-start ()
  (interactive)
  (advice-add 'persp-switch :before 'persp-enable-update-header-line)
  (advice-add 'persp-kill :before 'persp-enable-update-header-line)
  ;; (add-hook 'persp-mode-hook 'persp-tab-update-all-header-line)
  (add-hook 'window-configuration-change-hook 'persp-tab-update-all-header-line)
  (persp-tab-update-all-header-line))

(defun persp-tab-stop ()
  (interactive)
  (advice-remove 'persp-switch 'persp-enable-update-header-line)
  (advice-remove 'persp-kill 'persp-enable-update-header-line)
  ;; (remove-hook 'persp-mode-hook 'persp-tab-update-all-header-line)
  (remove-hook 'window-configuration-change-hook 'persp-tab-update-all-header-line)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (unless (persp-tab-ignore-bufferp (buffer-name buf))
        (setq header-line-format nil)))))



(provide 'persp-tab-mode)
;;; persp-tab-mode.el ends here
