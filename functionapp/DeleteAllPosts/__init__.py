import logging
import requests

import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Replace the URL with the actual API endpoint to delete all posts
    api_url = 'http://your-flask-app-domain.com/delete-all-posts'

    try:
        response = requests.delete(api_url)
        response.raise_for_status()
        return func.HttpResponse("All posts deleted successfully.", status_code=200)
    except requests.exceptions.HTTPError as e:
        logging.error(f"Failed to delete posts: {e}")
        return func.HttpResponse("Failed to delete posts.", status_code=500)
