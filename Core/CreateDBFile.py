#!/usr/local/bin/python3

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
    current_dir = os.path.dirname(os.path.realpath(__file__))
    image_id_file_path = os.path.join(str(current_dir), 'ImageID.txt')
    search_file = open(image_id_file_path, 'r', encoding='utf8')
    image_id_list = search_file.read().rstrip().splitlines()
    image_records = []
    fall_url_file_path = os.path.join(str(current_dir), 'fall11_urls.txt')
    with open(fall_url_file_path, 'r', encoding='utf8') as in_file:
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
    current_dir = os.path.dirname(os.path.realpath(__file__))
    imagenet_bbox_file_path = os.path.join(str(current_dir), 'imagenet.bbox.obtain_synset_list.txt')
    search_file = open(imagenet_bbox_file_path, 'r', encoding='utf8')
    imagenet_bbox_synset_list = search_file.read().rstrip().splitlines()
    image_dimensions_list = []
    for syn_set_id in imagenet_bbox_synset_list:
        image_db_dir = os.path.dirname(os.path.realpath(__file__))
        folder_path = os.path.normpath(str(current_dir) + "/Annotation/" + syn_set_id + "/Annotation/" + syn_set_id)
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


def create_id_synset_data():
    '''
    Reads the ImageID.txt text file line by line, get the id of image
    and create a text file of image names and id.

    :return: name_id_map.txt file
    '''
    current_dir = os.path.dirname(os.path.realpath(__file__))
    image_id_file_path = os.path.join(str(current_dir), 'ImageID.txt')
    search_file = open(image_id_file_path, 'r', encoding='utf8')
    image_id_list = search_file.read().rstrip().splitlines()
    id_synset_list = []
    for id in image_id_list:
        id_synset_list.append(id.split('\t')[0])
    from nltk.corpus import wordnet
    name_id_map = {}
    for id in id_synset_list:
        synset = wordnet._synset_from_pos_and_offset('n', int(id.split('n')[1]))
        for lemma in synset.lemmas():
            name_id_map[lemma.name().split(".")[0]] = id
    with open('name_id_map.txt', 'w') as file:
        for name, id in name_id_map.items():
            file.write(str(name) + ',' + str(id) + '\n')


if __name__ == '__main__':
    setup_db()
