;;; bv-latex.el --- Emacs configuration file -*- lexical-binding: t -*-

;; Copyright (C) 2024 Ayan Das <bvits@riseup.net>

;; Author: Ayan Das <bvits@riseup.net>
;; URL: https://github.com/b-vitamins/.config/emacs/lisp/bv-latex.el
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.3"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; "I can't go to a restaurant and order
;;  food because I keep looking at the fonts on the menu."
;;                                   - Donald Knuth

;;; Code:

(require 'ox-latex)

(defun bv-default-latex-output-dir ()
  "Determine the default output directory."
  (if (buffer-file-name)
      (file-name-directory (buffer-file-name))
    "~/"))

(defcustom bv-latex-output-dir (bv-default-latex-output-dir)
  "Output directory for compiled PDF files from LaTeX.
Defaults to the directory of the current Org file,
if available; otherwise, uses home."
  :type 'string
  :group 'bv-latex
  :set (lambda (symbol value)
         (set-default symbol (if (string-empty-p value)
                                 (bv-default-latex-output-dir)
                                 value))))

(defun bv-fix-graphics-paths (texfile)
  "Adjust \\includegraphics paths to absolute paths in TEXFILE.
Ensures image inclusions work correctly from any directory.

Assumptions:
- TEXFILE exists, is accessible, and not locked by another process.
- Paths in \\includegraphics are either correct relative paths
from TEXFILE or are already absolute.
- User has necessary permissions to read from and write back to TEXFILE.
- This function does not check if graphic files actually exist; 
it assumes paths, if relative, are correctly specified relative to TEXFILE.

TEXFILE is the path to a LaTeX document needing path adjustments for
\\includegraphics commands."
  (interactive "fSelect TEX file: ")
  (unless (file-exists-p texfile)
    (error "The specified file does not exist"))
  (let ((tex-dir (file-name-directory texfile)))
    (with-temp-buffer
      (insert-file-contents texfile)
      (goto-char (point-min))
      (while (re-search-forward "\\\\includegraphics\\(?:\\[.*?\\]\\)?{\\(.*?\\)}"
                                nil t)
        (let ((graphics-file (match-string 1)))
          (if (file-name-absolute-p graphics-file)
              (message "Skipping absolute path: %s" graphics-file)
            (let ((full-path (expand-file-name graphics-file tex-dir)))
              (if (file-exists-p full-path)
                  (replace-match full-path nil nil nil 1)
                (message "Missing graphic file: %s" full-path))))))
      (write-file texfile))))

(defun bv-org-latex-compile (texfile &optional snippet)
  "Compile a TeX file in a temporary directory and move the output PDF back.
This function adjusts paths in \\includegraphics commands to be absolute,
ensuring all graphics are included correctly regardless of the current working
directory.

Assumptions for successful execution:
- `org-latex-pdf-process' must be properly configured, and all commands it
  references (e.g., pdflatex, biber) must be available in the system's PATH.
- The environment for LaTeX compilation must be correctly set up, including
  necessary binaries and any dependencies specified in the LaTeX documents.
- TEXFILE provided must exist and be readable.
- The output directory specified by `bv-latex-output-dir' must be writable.
- Sufficient permissions must be granted to create and delete temporary
  directories within /tmp.

TEXFILE is the name of the file being compiled.  Processing is done through the
command specified in `org-latex-pdf-process'.  Output is redirected to
\"*Org PDF LaTeX Output*\" buffer.

When optional argument SNIPPET is non-nil, TEXFILE is a temporary file used to
preview a LaTeX snippet. In this case, simplify processing by not creating or
removing log files and skipping deletion of temporary files.

Returns the PDF file name or raises an error if it couldn't be produced. This
function is designed to be clean, not leaving any temporary files or directories
behind, regardless of the compilation's success or failure, unless processing a
snippet."
  (interactive "fSelect TEX file: ")  ; Prompts for the TEX file when called interactively
  (let* ((temp-dir (make-temp-file "/tmp/org-latex" t ""))
         (original-tex (expand-file-name (file-name-nondirectory texfile)))
         (temp-file (expand-file-name (file-name-nondirectory texfile) temp-dir))
         (out-file (expand-file-name (file-name-nondirectory
                                      (replace-regexp-in-string "\\.tex\\'"
                                                                ".pdf" texfile))
                                     bv-latex-output-dir))
         (log-buf-name "*Org PDF LaTeX Output*")
         (log-buf (if snippet nil (get-buffer-create log-buf-name))))
    (unwind-protect
        (progn
          (unless snippet
            (bv-fix-graphics-paths texfile)
            (with-temp-file temp-file
              (insert-file-contents texfile)))
          (let* ((default-directory temp-dir)
                 (process (if (functionp org-latex-pdf-process)
                              org-latex-pdf-process
                            (mapcar (lambda (command)
                                      (replace-regexp-in-string
                                       "%f" (shell-quote-argument
                                             (file-name-nondirectory temp-file))
                                       (replace-regexp-in-string
                                        "%b" (shell-quote-argument
                                              (file-name-base texfile)) command)))
                                    org-latex-pdf-process)))
                 (outfile (org-compile-file temp-file process "pdf"
                                            (format "See %S for details"
                                                    log-buf-name)
                                            log-buf)))
            (when (file-exists-p outfile)
              (rename-file outfile out-file t)
              (message "PDF file successfully produced and moved to %s" out-file)
              out-file)))
      (progn
        (when (and (not snippet) (file-exists-p temp-dir))
          (delete-directory temp-dir t 'recursive))
        (when (and (not snippet) (file-exists-p original-tex))
          (move-file-to-trash original-tex))
        (when log-buf (kill-buffer log-buf))))))

(provide 'bv-latex)
;;; bv-latex.el ends here