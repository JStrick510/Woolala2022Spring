# WooLaLa2020
New Build of WooLaLa mobile app built with Flutter and NodeJS

# GitHub Conventions
Develop will be our primary working branch which will be pulled into master after a review.
Checkout the develop branch and branch off from there.

Start new feature branches with: ft-feature-name
I have added a ft-facebook-login branch already

# Dev Env Startup:
Windows (Mac will be a little different)
Download Flutter:
https://flutter.dev/docs/get-started/install
Follow instructions on Website

Download Android Studio (IDE we will be using to develop)
-Make sure to download the latest AndroidSDK (it will prompt you to do this)
-There are two ways to test a flutter app
  1. On an android device connected via USB (Turn on Developer options in settings and enable USB debugging)
  2. (If you have an iPhone) Android device emulator on your computer (Available as a plugin in Android Studio that is relatively painless to setup)

You will need to install the flutter and dart plugins on android studio ass well.

The steps may be different on mac but the documentation on the flutter website will answer most of your questions. I will upload a base version of the project for us to begin working on and will work on locally for now until AWS is setup.

Supposedly this will work on iOS devices, but I am not sure how we will test it yet. Will need a dev account from Tito ($100 fee), so we will focus on Android for now.

A Good tutorial to follow for understanding how Flutter works:
https://flutter.dev/docs/get-started/codelab#step-1-create-the-starter-flutter-app

NodeJS server established locally for now - make sure NodeJS is installed on your machine

# MongoDB Atlas account:
  User: fashionxtllc@gmail.com
  Pwd: Fash10nxt*7

  You need to login to the account and add your IP address to the whitelist under the "Network Access" settings tab so that your computer can access the database.

  Limit Data upload because we are using a free tier account with 512MB of space.
  To use the mongodb client on app.js run after installing node:
      npm install mongoose

The app.js had the Product_Owner inserted into the request URI already, but feel free to change it or we can all operate off of the same admin account.
# Admins:
  Product_Owner
  owNONdfwaKARb9kH

  Lead_Devloper
  poQLxqdUb4c2RfvJ

# Users:
  Developer_1
  fOXG1slKKTNJDciP

  Developer_2
  5WhcVANplnf7BAep

  Developer_3
  RibMfjzEBwk2TNd8

  Developer_4
  MZhrCA6jE2VY23UM

# flutter note

The pubspec.yaml file apparently has some weird way to keep track of dependencies in terms of installing on local machines. We will probably run into this later, so keep note of when this file is changed.

If you cant find the DartSDK it is in: /flutter/bin/cache/dart-sdk

# Cucumber test

To run cucumber test, direct to woolala_app folder and run:
```flutter drive --target=test_driver/app.dart```
