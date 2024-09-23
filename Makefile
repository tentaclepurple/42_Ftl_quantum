.PHONY: get_token up all

all: get_token up open
	@echo "All done!"

get_token:
	@if [ -f .env ]; then \
		echo ".env file already exists. Skipping token input."; \
	else \
		echo "Go to https://quantum.ibm.com/ and paste your IBM QUANTUM token here:"; \
		read token; \
		echo "IBM_TOKEN=$$token" > .env; \
		echo ".env file created with IBM_TOKEN=$$token"; \
	fi

up:
	@echo "Starting the JupyterLab container..."
	@docker compose up -d
	@echo "Waiting for JupyterLab to start..."
	@while ! docker logs jupyter_lab 2>&1 | grep -q 'http://127.0.0.1:8888/lab?token'; do \
		sleep 5; \
	done
	@echo "JupyterLab is ready!"

open:
	@echo "Finding the JupyterLab URL..."
	@URL=$$(docker logs jupyter_lab 2>&1 | grep 'http://127.0.0.1:8888/lab?token' | tail -n 1); \
	echo "JupyterLab URL: $$URL"; \
	UNAME_S=$$(uname -s); \
	if [ "$$UNAME_S" = "Linux" ] && [ "$$(grep -i microsoft /proc/version)" ]; then \
		echo "Detected WSL."; \
		cmd.exe /c start $$URL; \
	elif [ "$$UNAME_S" = "Linux" ]; then \
		echo "Detected Linux."; \
		xdg-open $$URL || echo "Failed to open the URL in the browser."; \
	else \
		echo "Unknown OS. Failed to open the URL."; \
	fi
	@echo "Opening the browser. Enjoy your Ftl_Quantum in JupyterLab notebooks!";


run:
	@docker logs jupyter_lab
	
down:
	@docker compose down

jupyter:
	@docker exec -it jupyter_lab bash

clean: down
	yes | docker system prune -a