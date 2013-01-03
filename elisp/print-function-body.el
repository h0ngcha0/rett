(require 'rett-rest)

(defun rett-rest-put-function-body (id body)
  "Display an editor on the web page"
  (rett-rest-put "editors" (number-to-string id) body))

(defun rett-construct-editor-body (id x y z code)
  (concat "{\"x\":" (number-to-string x) ",\"y\":" (number-to-string y) ",\"z\":" (number-to-string z) ",\"id\":\"" (number-to-string id) "\",\"code\":\"" code "\"}"))

;; set a temporary id with an auto-increasing sequence 1, default is 1
(setq id 1)

;; send function body to web
(defun search-local-function-and-print (function arity)
  "Goto the definition of FUNCTION/ARITY in the current buffer."
  (save-excursion
    (let ((str (concat "\n" function "("))
          (searching t)
          start end)
      (goto-char (point-min))
      (while searching
        (cond ((search-forward str nil t)
               (backward-char)
               (when (or (null arity)
                         (eq (ferl-arity-at-point) arity))
                 (setq start (progn (beginning-of-line) (point)))
                 ;; output function body and goto original position
                 ;; !bug fixed: if function is not finished, erlang-end-of-function will get the end of next function
                 ;;(setq end (progn (erlang-end-of-function) (point)))
                 (save-excursion
                   (setq end (get-function-end start)))
                 ;; push function body on webserver, with default parameters x y z method id code, temporarily set id = id + 1
                 (setq id (1+ id))
                 (rett-rest-put-function-body id (rett-construct-editor-body id 1 1 1 (buffer-substring-no-properties start end)))
                 ;;(write-region start end "~/test.txt")
                 (setq searching nil)))
              (t
               (setq searching nil)
               (if arity
                   (message "Couldn't find function %S/%S" function arity)
                 (message "Couldn't find function %S" function))))))))

(defun find-source (module function arity)
  "Find the source code for MODULE in a buffer, loading it if necessary.
When FUNCTION is specified, the point is moved to its start."
  (interactive)
  (let (start end)
    (if (or (equal module (erlang-get-module))
            (string-equal module "MODULE"))
	;; try to look for function in current buffer
        (if function
            (progn
              (search-local-function-and-print function arity))
            (null (error "Function %s:%s/%s not found" module function arity)))
        ;; look for function in other files Issue
        (let* ((node (edts-project-buffer-node-name (current-buffer)))
               (info (edts-get-function-info node module function arity)))
          (if info
	      ;; if function is found, use temp buffer to open the source file and locate the function body and output.
	      (with-temp-buffer
		(progn
		  (insert-file-contents (cdr (assoc 'source info)))
		  (goto-line (cdr (assoc 'line info)))
		  ;;(write-region (point-min) (point-max) "~/test.txt")
		  (setq start (point))
		  (setq end (progn (erlang-end-of-function) (point)))
		  ;; push function body on webserver, with default parameters x y z method id code, temporarily set id = id + 1
		  (setq id (+ 1 id))
                  (rett-rest-put-function-body id (rett-construct-editor-body id 1 1 1 (buffer-substring-no-properties start end)))
		  ;;(write-region start end "~/test.txt")
	      ))
              (null
               (error "Function %s:%s/%s not found" module function arity)))))))

(defun rest-function-body-under-cursor ()
  (interactive)
  (cond
   ;; look for a include/include_lib
   ((edts-header-under-point-p) (edts-find-header-source))
   ((edts-macro-under-point-p)  (edts-find-macro-source))
   ;; look for a M:F/A
   ((apply #'find-source
           (or (ferl-mfa-at-point) (error "No call at point."))))))

;; rest all function bodies
(defun rest-all-function-bodies()
  (interactive)
  (save-excursion
    (let (funcall_point fun_start fun_end)
      (setq fun_start (progn (erlang-beginning-of-function) (point)))
      ;; get the end point of current function
      (setq fun_end (get-function-end fun_start))
      (while (re-search-forward ":?[a-z][0-9A-Za-z_]*[ \t]*(" fun_end t)
        (setq funcall_point (point))
        (backward-char)
        (skip-chars-backward "[ \t]*")
        (rest-function-body-under-cursor)
        (goto-char funcall_point)))))

;; return the function's end point with no moved cursor
(defun get-function-end(fun_start)
  (save-excursion
    ;; erlang function definition head regexp
    (let ((fun_head_query "^[ \t]*[a-z][a-zA-Z0-9_]*[ \t]*([ \t]*\\([A-Z_][a-zA-Z0-9_]*,[ \t]*\\)*[A-Z_][a-zA-Z0-9_]*[ \t]*)[ \t]*->.*"))
      ;;     (fun_end_query ".*%+.*\\..*")
      ;;     fun_line_start fun_line_end line_num)
      ;; (setq fun_line_start (line-number-at-pos (goto-char fun_start)))
      ;;  (end-of-line)
       ;; get next function's head position
      (end-of-line)
       (if (re-search-forward fun_head_query nil t)
           (progn
             (previous-line)
             ;; (setq fun_line_end (line-number-at-pos (point)))
             ;; ;; try to find '.' as the end of current function if the function is finished
             ;; (catch 'found_fun_end
             ;;   (while (>= fun_line_end fun_line_start)
             ;;     (goto-line fun_line_end)
             ;;   ;; search '.' in current line
             ;;     (if (re-search-forward "^[^%]*\\." (line-end-position) t)
             ;;         (throw 'found_fun_end nil)
             ;;      (setq fun_line_end (1- fun_line_end)))))
             (line-end-position))
             ;; set current function end as buffer end if no more function definition
             (point-max)))))





(setq debug nil)
(setq logfile "~/log")
(defun output-debug(str)
  (interactive)
  (if debug
      (progn
      (with-temp-buffer
	(insert (concat str "\n"))
	(append-to-file (point-min) (point-max) logfile)))))

 (remove-hook 'after-save-hook
 	  (lambda()
 	    (rest-all-function-bodies)
 	    (print (point))))
 (add-hook 'after-save-hook
 	  (lambda()
 	    (rest-all-function-bodies)
 	    (print (point))))
