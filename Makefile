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
	xdg-open $$URL || echo "Failed to open the URL in the browser.";
	@echo "Opening the browser with the URL: $$URL";
	
#cmd.exe /c start $$URL || echo "Failed to open the URL in the default browser."


run:
	@docker logs jupyter_lab
	
down:
	@docker compose down

python:
	@docker exec -it python bash

jupyter:
	@docker exec -it jupyter_lab bash

clean: down
	yes | docker system prune -a