#!/usr/local/bin/python3

from urllib3 import disable_warnings
from urllib3 import PoolManager
from urllib3.util.timeout import Timeout
from urllib3.exceptions import InsecureRequestWarning

import os
import random
import shutil
import sqlite3
import time

disable_warnings(InsecureRequestWarning)


def check_url(url):
    '''
    Verify the url before fetching the image.

    :param url: url string
    :return: TRUE or FALSE
    '''
    try:
        timeout = Timeout(connect=1.0, read=1.0)
        conn = PoolManager()
        response = conn.request('HEAD', url, timeout=timeout)
        status = int(response.status)
        is_url_valid = False

        # Check the HTTP response status code and whether the url redirects to another page
        if status in range(200, 209) and response.get_redirect_location() is False:

            # Check the content length of the response(if present) to verify whether the url
            # contains an image which can be used in scene creation
            content_length = int(response.headers.get('Content-Length', 0))
            if content_length != 0 and content_length > 2100:
                is_url_valid = True

        conn.clear()
        return is_url_valid

    except Exception:
        return False


def fetch_images_with_urls(word_net_id_list):
    '''
    Download the images with url and store them on the local folder.

    :param word_net_id_list: list of wordnet ids
    :return: none
    '''
    image_db_dir = os.path.dirname(os.path.realpath(__file__))
    db_conn = sqlite3.connect(os.path.join(str(image_db_dir),"ImageNet.db"))
    c = db_conn.cursor()
    http_conn = PoolManager()
    for word_net_id in word_net_id_list:

        # Create a list of image ids that will be fetched
        image_id_list = []
        image_file_dir = os.path.dirname(os.path.realpath(__file__))
        image_id_file_path = os.path.join(str(image_file_dir), 'ImageID.txt')
        with open(image_id_file_path, 'r', encoding='utf8') as out_file:
            for line in out_file:
                if line.startswith(word_net_id):
                    image_id_list = line.split("\t")[1].strip().split(',')
                    break

        # Check how many images are downloaded for the target noun object
        file_path = os.path.dirname(os.path.realpath(__file__))
        image_folder_path = os.path.join(file_path, 'Images', word_net_id)
        if not os.path.exists(image_folder_path):
            os.makedirs(image_folder_path)
        url_count = len(os.listdir(image_folder_path))

        # Randomly download the images for the target noun object
        random.shuffle(image_id_list)
        start_time = time.time()
        for image_id in image_id_list:
            if url_count < 10 and image_id.startswith(word_net_id):

                # First, find the url of the image from the database
                url = c.execute('SELECT URL from ImageNetURLs WHERE ImageID=(?) ORDER BY RANDOM() LIMIT 10', (image_id,)).fetchone()
                if url is not None:
                    if check_url(url[0]) is not False:

                        # Second, fetch the image
                        timeout = Timeout(connect=5.0, read=10.0)
                        response = http_conn.request('GET', url[0], preload_content=False, timeout=timeout)
                        file_name = os.path.normpath(image_folder_path + "/" + image_id + ".png")

                        # Last, save the image on the local directory
                        out_file = open(file_name, 'wb')
                        shutil.copyfileobj(response, out_file)
                        url_count = url_count + 1

        # print("Image directory: " + image_folder_path)
        # print("--- %s seconds (Get Images) ---" % (time.time() - start_time))
    c.close()


def fetchImages(word_net_id_dict):
    '''
    Create the folders to store the fetched images and fetch images.

    :param word_net_id_dict: wordnet id dictionary
    :return: none
    '''
    word_net_id_list = []
    for noun, word_net_id in word_net_id_dict.items():
        file_path = os.path.dirname(os.path.realpath(__file__))
        image_folder_path = os.path.join(file_path, 'Images', word_net_id)

        if not os.path.exists(image_folder_path):
            word_net_id_list.append(word_net_id)

    # Only fetch the noun object's images that does not exist already
    if word_net_id_list:
        fetch_images_with_urls(word_net_id_list)


def fetchAllImages():
    '''
    Fetch all images that are in the ImageId.txt file.

    :return: none
    '''
    word_net_id_list = []
    file_path = os.path.dirname(os.path.realpath(__file__))
    image_id_file_path = os.path.join(str(file_path), 'ImageID.txt')
    with open(image_id_file_path, 'r', encoding='utf8') as out_file:
        for line in out_file:
            word_net_id_list.append(line.split("\t")[0].strip())
    word_net_id_list_to_fetch = []
    for word_net_id in word_net_id_list:
        file_path = os.path.dirname(os.path.realpath(__file__))
        image_folder_path = os.path.join(file_path, 'Images', word_net_id)

        if not os.path.exists(image_folder_path):
            word_net_id_list_to_fetch.append(word_net_id)
        else:
            files = os.listdir(image_folder_path)
            if len(files) < 10:
                word_net_id_list_to_fetch.append(word_net_id)

    # Only fetch the noun object's images that does not exist already
    if word_net_id_list_to_fetch:
        fetch_images_with_urls(word_net_id_list_to_fetch)

if __name__ == '__main__':
    fetchAllImages()