#!/usr/bin/env python3
# File: color_helper.py
# Location: https://bgstack15.ddns.net/cgit/inventory_pouches
# Author: bgstack15
# Startdate: 2025-03-27-5 15:01
# Title: Print Color Strings for Dyes
# Purpose: print out dye colors based on texture images for minetest_game
# Project: inventory_pouches
# History:
# Usage: ./color_helper.py ~/.var/app/net.minetest.Minetest/.minetest/games/minetest_game
# Reference:
#    https://stackoverflow.com/questions/3380726/converting-an-rgb-color-tuple-to-a-hexidecimal-string/43572620#43572620
# Improve:
# Dependencies:
#    dep-devuan: python3-pil
import os, sys
from PIL import Image

def rgba2hex(rgba):
    return "#{:02x}{:02x}{:02x}".format(rgba[0],rgba[1],rgba[2])

def get_color_from_texture_file(infile):
   key = os.path.basename(infile).replace("_",":",1).replace(".png","")
   with Image.open(infile) as im:
      pix = im.load()
      # grab a useful pixel
      value = pix[8,8]
      return '    {"' + key + '","' + rgba2hex(value) + '"},'
   return None

def print_texture_files(directory):
   x = 0
   directory = directory.rstrip("/")
   if os.path.basename(directory) == "minetest_game":
      directory = directory + "/mods/dye"
   for root, subdir, files in os.walk(directory):
      for i in files:
         x = x + 1
         if x == 1:
            print("inventory_pouches.dye_color_pairs = {")
         if i.endswith(".png"):
            print(get_color_from_texture_file(os.path.join(root,i)))
   if x > 0:
      print("}")

# pass either path to minetest_game or its mods/dye
print_texture_files(sys.argv[1])
