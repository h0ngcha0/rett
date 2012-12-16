;; set a temporary id with an auto-increasing sequence 1, default is 1
(setq id 1)

;; send function body to web
(defun put-function-body-on-web-with-rest (x y z method id code)
  (interactive)
  (let* ((url                       (concat "http://127.0.0.1:8642/editors/" id))
         (url-request-method        method)
         (url-request-extra-headers (list '("Content-Type" . "application/json")))
         (url-request-data          (concat "{\"x\":" x ",\"y\":" y ",\"z\":" z ",\"id\":\"" id "\",\"code\":\"" code "\"}"))
         (url-show-status           nil))
    (edts-log-debug "Sending %s-request to %s" "PUT" url)
    (let ((buffer (url-retrieve-synchronously url)))
      (when buffer
	(with-current-buffer buffer
	  (print buffer)
          (edts-rest-parse-http-response))))))

(defun search-local-function-and-print (function arity)
  "Goto the definition of FUNCTION/ARITY in the current buffer."
  (let ((origin (point))
	(str (concat "\n" function "("))
	(searching t)
	start end)
    (goto-char (point-min))
    (while searching
      (cond ((search-forward str nil t)
	     (backward-char)
	     (when (or (null arity)
		       (eq (ferl-arity-at-point) arity))
	       (beginning-of-line)
	       (setq start  (point))
	       ;; output function body and goto original position
	       (erlang-end-of-function)
	       (setq end  (point))
	       ;; push function body on webserver, with default parameters x y z method id code, temporarily set id = id + 1
	       (setq id (+ 1 id))
	       (put-function-body-on-web-with-rest (number-to-string 1) (number-to-string 1) (number-to-string 1) "PUT" (number-to-string id) (buffer-substring start end))
	       ;;(write-region start end "~/test.txt")
	       (goto-char origin)
	       (setq searching nil)))
	    (t
	     (setq searching nil)
	     (goto-char origin)
	     (if arity
		 (message "Couldn't find function %S/%S" function arity)
	       (message "Couldn't find function %S" function)))))))

(defun find-source (module function arity)
  "Find the source code for MODULE in a buffer, loading it if necessary.
When FUNCTION is specified, the point is moved to its start."
  (interactive)
  ;; Add us to the history list
  (let ((mark (copy-marker (point-marker))) start end)
    (if (or (equal module (erlang-get-module))
            (string-equal module "MODULE"))
	;; try to look for function in current buffer
        (if function
            (progn
              (ring-insert-at-beginning (edts-window-history-ring) mark)
              (search-local-function-and-print function arity))
            (null (error "Function %s:%s/%s not found" module function arity)))
        ;; look for function in other files Issue
        (let* ((node (edts-project-buffer-node-name (current-buffer)))
               (info (edts-get-function-info node module function arity)))
          (if info
	      ;; if function is found, use temp buffer to open the source file and locate the function body and output.
	      (with-temp-buffer
		(progn
		  ;;(find-file-existing (cdr (assoc 'source info)))
		  (insert-file-contents (cdr (assoc 'source info)))
		  (ring-insert-at-beginning (edts-window-history-ring) mark)
		  (goto-line (cdr (assoc 'line info)))
		  ;;(write-region (point-min) (point-max) "~/test.txt")
		  (setq start (point))
		  (erlang-end-of-function)
		  (setq end (point))
		  ;; push function body on webserver, with default parameters x y z method id code, temporarily set id = id + 1
		  (setq id (+ 1 id))
		  (put-function-body-on-web-with-rest (number-to-string 1) (number-to-string 1) (number-to-string 1) "PUT" (number-to-string id) (buffer-substring start end))
		  ;;(write-region start end "~/test.txt")
	      ))
              (null
               (error "Function %s:%s/%s not found" module function arity)
))))))

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
  (let (old_pos correct_start start end times)
  (setq old_pos (point))
  (erlang-beginning-of-function)
  (setq correct_start (point))
  ;; go to end first,  if function is not finished, it will go to the next function's end or end of file.
  (erlang-end-of-function)
  (setq end (point))
  ;; if function is not finished, the start postion will be different
  (erlang-beginning-of-function)
  (setq start (point))
  (if (/= correct_start start)
      (setq end (- start 1)))
  ;; start from correct beginning
  (goto-char correct_start)
  (setq times 0)
  (while (re-search-forward ":*[a-z][0-9A-Za-z_]*(" end t)
    (backward-char)
    (rest-function-body-under-cursor)
    (setq times (+ 1 times))
    (output-debug (concat (number-to-string times) " time to push to web. current position is " (number-to-string (point))))
    (forward-char))
  ;; stay at original position
  (goto-char old_pos)
  (output-debug (concat "go to position " (number-to-string old_pos)))))


(setq debug nil)
(setq logfile "~/log")
(defun output-debug(str)
  (interactive)
  (if debug
      (progn
      (with-temp-buffer
	(insert (concat str "\n"))
	(append-to-file (point-min) (point-max) logfile)))))


;; (remove-hook 'after-save-hook 
;; 	  (lambda() 
;; 	    (rest-all-function-bodies)
;; 	    (print (point))))
;; (add-hook 'after-save-hook 
;; 	  (lambda() 
;; 	    (rest-all-function-bodies)
;; 	    (print (point))))

