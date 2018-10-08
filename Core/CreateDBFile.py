#!/usr/bin/env python3

import sqlite3
import os
import xml.etree.ElementTree as et


def setup_db():
    '''
    This function sets up the database and stores the data into it.

    :return: none
    '''
    # Create a connection object that represents the ImageNet database.
    conn = sqlite3.connect("ImageNetData.db")
    c = conn.cursor()

    # Create table.
    c.execute("CREATE TABLE IF NOT EXISTS ImageNetURLs (ImageID text PRIMARY KEY UNIQUE, Url text)")
    c.execute("CREATE TABLE IF NOT EXISTS ImageDimensions (ImageID text PRIMARY KEY UNIQUE, width integer, "
              "height integer, bb_xmin integer, bb_ymin integer, bb_xmax integer, bb_ymax integer)")

    # Get the image id and url.
    image_records = get_url_data()

    # Get the dimensions.
    image_dimension_records = get_dimension_data()

    # Insert data into table.
    c.executemany('INSERT OR IGNORE INTO ImageNetURLs VALUES (?,?)', image_records)
    c.executemany('INSERT OR IGNORE INTO ImageDimensions VALUES (?,?,?,?,?,?,?)', image_dimension_records)

    # Save (commit) the changes.
    conn.commit()

    # Close the connection.
    c.close()


def get_url_data():
    '''
    Reads the text file line by line, get the name and url of each image
    and create lists of image names and urls.

    :return: none
    '''
    search_file = open('ImageID.txt', 'r', encoding='utf8')
    image_id_list = search_file.read().rstrip().splitlines()
    image_records = []
    with open('fall11_urls.txt', 'r', encoding='utf8') as in_file:
        for line in in_file:
            image_record = []
            line = line.rstrip().split("\t")
            image_id = line[0].rstrip()
            print(image_id)
            if image_id in image_id_list:
                image_record.append(image_id)
                image_record.append(line[1].rstrip())
                image_records.append(image_record)
    return image_records


def get_dimension_data():
    '''
    Reads the text file line by line, get the dimension of each image
    and create lists of image dimension.

    :return: none
    '''
    search_file = open('imagenet.bbox.obtain_synset_list.txt', 'r', encoding='utf8')
    imagenet_bbox_synset_list = search_file.read().rstrip().splitlines()
    image_dimensions_list = []
    for syn_set_id in imagenet_bbox_synset_list:
        folder_path = os.path.normpath("./Annotation/" + syn_set_id + "/Annotation/" + syn_set_id)
        if os.path.isdir(folder_path):
            for image_file in os.listdir(folder_path):
                image_dimension_record = []
                tree = et.parse(folder_path + "/" + image_file)
                image_ID = tree.findtext(".//filename")
                image_dimension_record.insert(0, image_ID)
                width = int(tree.findtext('.//size/width'))
                image_dimension_record.insert(1, width)
                height = int(tree.findtext('.//size/height'))
                image_dimension_record.insert(2, height)
                index = 3
                for node in tree.findall('.//object/bndbox/'):
                    if index <= 6:
                        image_dimension_record.insert(index, int(node.text))
                        index = index + 1
                image_dimensions_list.append(image_dimension_record)
    return image_dimensions_list


if __name__ == '__main__':
    setup_db()
