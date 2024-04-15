(use-modules (gnu packages emacs)
	     (gnu packages emacs-xyz)
             (myguix packages emacs-pqrs))

(specifications->manifest '("my-emacs"
			    "emacs-modus-themes"
			    "emacs-doom-themes"
			    "emacs-doom-modeline"
			    "emacs-rainbow-delimiters"
			    "emacs-rainbow-mode"
			    "emacs-adaptive-wrap"
			    "emacs-smartparens"
			    "emacs-nerd-icons"
			    "emacs-nerd-icons-dired"
			    "emacs-nerd-icons-corfu"
			    "emacs-nerd-icons-ibuffer"
			    "emacs-nerd-icons-completion"
			    "emacs-kind-icon"
			    "emacs-all-the-icons"
			    "emacs-no-littering"
			    "emacs-guix"
			    "emacs-mjolnir-mode"
			    "emacs-windsize"
			    "emacs-ace-window"
			    "emacs-olivetti"
			    "emacs-which-key"
			    "emacs-org-fragtog"
			    "emacs-vertico"
			    "emacs-orderless"
			    "emacs-marginalia"
			    "emacs-consult"
			    "emacs-corfu"
			    "emacs-embark"
			    "emacs-citar"
			    "emacs-org-roam"
			    "emacs-websocket"
			    "emacs-simple-httpd"
			    "emacs-org-roam-ui"
			    "emacs-pdf-tools"
			    "emacs-dired-hacks"
			    "emacs-oauth2"
			    "emacs-pinentry"
			    "emacs-auth-source-pass"
			    "emacs-password-store"
			    "emacs-yasnippet"
			    "emacs-geiser"
			    "emacs-geiser-guile"
			    "emacs-lsp-mode"
			    "emacs-lsp-ui"
			    "emacs-flycheck"
			    "emacs-flycheck-inline"
			    "emacs-flycheck-guile"
			    "emacs-flycheck-package"
			    "emacs-flycheck-rust"
			    "emacs-flycheck-haskell"
			    "emacs-lsp-jedi"
			    "emacs-rust-mode"
			    "emacs-rustic"
			    "emacs-haskell-mode"
			    "emacs-gnuplot"
			    "emacs-lua-mode"
			    "emacs-json-mode"
			    "emacs-dockerfile-mode"
			    "emacs-yaml-mode"
			    "emacs-toml-mode"
			    "emacs-julia-mode"
			    "emacs-cmake-mode"
			    "emacs-god-mode"
                            "emacs-gptel"
                            "emacs-magit"
                            "emacs-auctex"
                            "emacs-jit-spell"
                            "emacs-web-mode"))
