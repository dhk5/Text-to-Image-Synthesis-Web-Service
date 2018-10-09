#!/usr/local/bin/python3

import numpy as np
import cv2

import sqlite3
import os
import time


def process_images(image_path_list):
    '''
    This method uses the GrabCut algorithm to remove the background of the images.

    :param image_path_list: list of the image paths
    :return: none
    '''
    conn = sqlite3.connect("ImageNet.db")
    c = conn.cursor()

    # The 'ProcessedImages' folder in the 'Images' directory consists of the images
    # after background subtraction.
    processed_image_folder = os.path.join(os.getcwd(), "Images", "ProcessedImages")
    if not os.path.exists(processed_image_folder):
        os.makedirs(processed_image_folder)

    processed_image_path_list = []
    for image_path in image_path_list:
        image_name = os.path.basename(image_path)
        processed_image_path = os.path.join(processed_image_folder, image_name)

        # The GrabCut algorithm will run only if the image is not already
        # in the 'ProcessedImages' folder.
        if not os.path.exists(processed_image_path):
            image_id = os.path.splitext(image_name)[0]

            # Obtain the dimensions of the image and the dimensions of the bounding box
            # containing the object represented by the noun.
            start_time = time.time()
            image_dimensions = c.execute('SELECT * from ImageDimensions where ImageID=?', (image_id,)).fetchone()
            img = cv2.imread(image_path)

            mask = np.zeros(img.shape[:2], np.uint8)
            bgdModel = np.zeros((1, 65), np.float64)
            fgdModel = np.zeros((1, 65), np.float64)
            x1 = image_dimensions[3]
            y1 = image_dimensions[4]
            x2 = image_dimensions[5]
            y2 = image_dimensions[6]
            width = x2 - x1
            height = y2 - y1
            rect = (x1, y1, width, height)
            cv2.grabCut(img, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_RECT)

            # Add alpha channel to the image.
            r_channel, g_channel, b_channel = cv2.split(img)
            a_channel = np.where((mask == 2) | (mask == 0), 0, 225).astype('uint8')
            img = cv2.merge((r_channel, g_channel, b_channel, a_channel))

            # Crop the image using the bounding box dimensions.
            img = img[y1:y2, x1:x2]

            # Write the image to the 'ProcessedImages' folder.
            cv2.imwrite(processed_image_path, img)
            print("--- %s seconds(GrabCut) ---" % (time.time() - start_time))

        processed_image_path_list.append(processed_image_path)
    return processed_image_path_list


def overlay_image_alpha(img, img_overlay, pos):
    '''
    Overlay img_overlay on top of the image at the position specified
    by pos and blend using alpha_mask.

    :param img: image
    :param img_overlay: image overlay
    :param pos: position
    :return: none
    '''
    # Size of foreground image.
    h, w, _ = img_overlay.shape

    # Size of background image.
    rows, cols, _ = img.shape

    # Position of foreground/overlay image.
    y, x = pos[0], pos[1]

    # Loop over all pixels and apply the blending equation.
    for i in range(h):
        for j in range(w):
            if x + i >= rows or y + j >= cols:
                continue

            # Read the alpha channel.
            alpha = float(img_overlay[i][j][3] / 255.0)
            img[x + i][y + j] = alpha * img_overlay[i][j][:3] + (1 - alpha) * img[x + i][y + j]


def image_resize(image, width=None, height=None, inter=cv2.INTER_AREA):
    '''
    Function to resize the image and keeping the aspect ratio.

    :param image:
    :param width:
    :param height:
    :param inter:
    :return:
    '''
    # Get the original image height and width.
    (h, w) = image.shape[:2]

    # If both the width and height are None, then return the original image.
    if width is None and height is None:
        return image

    # Check to see if the width is None.
    if width is None:

        # Calculate the ratio of the height and construct the dimensions.
        r = height / float(h)
        dim = (int(w * r), height)

    else:
        # Calculate the ratio of the width and construct the dimensions.
        r = width / float(w)
        dim = (width, int(h * r))

    # Resize the image.
    resized = cv2.resize(image, dim, interpolation=inter)

    # Return the resized image.
    return resized


def calculateCoordinates(image, image_id):
    '''
    Calculate the bounding box coordinates.

    :param image:
    :param image_id:
    :return:
    '''
    conn = sqlite3.connect("ImageNet.db")
    c = conn.cursor()

    # Get image dimensions
    image_height, image_width = image.shape[0:2]
    image_dimensions = c.execute('SELECT * from ImageDimensions where ImageID=?', (image_id,)).fetchone()
    original_width, original_height = image_dimensions[1], image_dimensions[2]

    # Scale the image
    scale_x = round(image_width / original_width, 2)
    scale_y = round(image_height / original_height, 2)

    # Calculate the bounding box coordinates
    new_bb_x1 = round(scale_x * image_dimensions[3])
    new_bb_y1 = round(scale_y * image_dimensions[4])
    new_bb_x2 = round(scale_x * image_dimensions[5])
    new_bb_y2 = round(scale_y * image_dimensions[6])

    return new_bb_x1, new_bb_y1, new_bb_x2, new_bb_y2


def generateImage(processed_image_path_list, preposition):
    '''
    Create the scene visualizing the sentence. The object indicating the dependent noun
    is placed according to the preposition in the image containing the main noun object.

    :param processed_image_path_list:
    :param preposition:
    :return: none
    '''
    start_time = time.time()
    main_noun_image_width = 320
    dep_noun_image_width = 160
    main_noun_image_height = 240
    dep_noun_image_height = 120
    border_gap_1 = 10
    border_gap_2 = 40
    above_gap = 120
    near_gap = 10
    below_gap = 120

    # Resize the image of the main noun.
    main_noun_image_name = os.path.basename(processed_image_path_list[0])
    dep_noun_image_name = os.path.basename(processed_image_path_list[1])
    dep_noun_image_name = os.path.splitext(dep_noun_image_name)[0]

    # Write the image to the 'ProcessedImages' folder.
    preposition_folder_path = os.path.join(os.path.dirname(processed_image_path_list[0]), preposition)
    if not os.path.exists(preposition_folder_path):
        os.makedirs(preposition_folder_path)
    created_image_path = os.path.join(preposition_folder_path, dep_noun_image_name + main_noun_image_name)
    if os.path.exists(created_image_path):
        return

    main_noun_image = cv2.imread(processed_image_path_list[0], cv2.IMREAD_UNCHANGED)
    # main_noun_image = image_resize(main_noun_image, width=main_noun_image_width)
    main_noun_image = cv2.resize(main_noun_image, (main_noun_image_width, main_noun_image_height))
    main_image_height, main_image_width = main_noun_image.shape[0:2]
    width_mid_bg = round(main_image_width / 2)
    height_mid_bg = round(main_image_height / 2)

    # Resize the image of the dependent noun.
    dep_noun_image = cv2.imread(processed_image_path_list[1], cv2.IMREAD_UNCHANGED)
    dep_image_height, dep_image_width = dep_noun_image.shape[0:2]
    if dep_image_height > dep_image_width:
        dep_noun_image = image_resize(dep_noun_image, height=dep_noun_image_height)
    else:
        dep_noun_image = image_resize(dep_noun_image, width=dep_noun_image_width)
    dep_image_height, dep_image_width = dep_noun_image.shape[0:2]
    width_mid_fg = round(dep_image_width / 2)
    height_mid_fg = round(dep_image_height / 2)
    three_quarter_left_fg = round(dep_image_height * 0.75)
    quarter_left_fg = round(dep_image_height * 0.25)

    background_image = cv2.imread('./Icons/light-veneer.png')
    background_image = cv2.resize(background_image, (main_image_width * 3, main_image_height * 3))
    background_image_height, background_image_width = background_image.shape[0:2]
    height_mid_canvas = round(background_image_height / 2)
    width_mid_canvas = round(background_image_width / 2)

    # Place the image of the main noun on canvas.
    if preposition == 'above':
        # Place the image of the main noun at the bottom of the canvas.
        center_x = width_mid_canvas - width_mid_bg
        center_y = background_image_height - main_noun_image_height - border_gap_2
        overlay_image_alpha(background_image, main_noun_image, (center_x, center_y))
    elif preposition == 'between':
        # Place two images of the main noun at both ends of the canvas.
        center_x = border_gap_1
        center_y = height_mid_canvas - height_mid_bg
        overlay_image_alpha(background_image, main_noun_image, (center_x, center_y))
        center_x = background_image_width - main_noun_image_width - border_gap_1
        overlay_image_alpha(background_image, main_noun_image, (center_x, center_y))
    elif preposition == 'below':
        # Place the image of the main noun at the top of the canvas.
        center_x = width_mid_canvas - width_mid_bg
        center_y = border_gap_2
        overlay_image_alpha(background_image, main_noun_image, (center_x, center_y))
    else:
        # Place the image of the main noun at the center of a canvas.
        center_x = width_mid_canvas - width_mid_bg
        center_y = height_mid_canvas - height_mid_bg
        overlay_image_alpha(background_image, main_noun_image, (center_x, center_y))

    # Calculate the new coordinates of the bounding box containing the image of the main noun on the canvas.
    bb_x1_main = center_x
    bb_y1_main = center_y
    bb_x2_main = main_image_width + center_x
    bb_y2_main = main_image_height + center_y

    # Calculate the position to place the image of the dependent noun based on the preposition.
    if preposition == 'above':
        pos_x = bb_x1_main + (width_mid_bg - width_mid_fg)
        pos_y = bb_y1_main - dep_noun_image_height - above_gap
    elif preposition == 'near':
        pos_x = bb_x1_main - dep_noun_image_width - near_gap
        pos_y = bb_y1_main + (height_mid_bg - height_mid_fg)
    elif preposition == 'between':
        pos_x = width_mid_canvas - width_mid_fg
        pos_y = height_mid_canvas - height_mid_fg
    elif preposition == 'below':
        pos_x = bb_x1_main + (width_mid_bg - width_mid_fg)
        pos_y = bb_y2_main + dep_noun_image_height + below_gap
    elif preposition == 'beside':
        pos_x = bb_x2_main - three_quarter_left_fg
        pos_y = bb_y1_main + (height_mid_bg - height_mid_fg)
    elif preposition == 'on':
        pos_x = bb_x1_main + (width_mid_bg - width_mid_fg)
        pos_y = bb_y1_main - three_quarter_left_fg
    elif preposition == 'under':
        pos_x = bb_x1_main + (width_mid_bg - width_mid_fg)
        pos_y = bb_y2_main
    else:
        pos_x = 0
        pos_y = 0

    # Place the image of the dependent noun on the canvas containing the image of the main noun at the coordinates
    # calculated according to the preposition.
    overlay_image_alpha(background_image, dep_noun_image, (pos_x, pos_y))

    cv2.imwrite(created_image_path, background_image)

    print("--- %s seconds(Create Image) ---" % (time.time() - start_time))
    return created_image_path
