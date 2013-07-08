# Warrior Family Tree #
by Paul Graham 
graham.paul+github@gmail.com

Requires: MOAI host ([http://getmoai.com][moai]).


## What Does It Do? ##

It displays an example family tree that is loaded from a specially prepared file.


## What Is It? ##

*Warrior Family Tree* is an experimental program that was written to explore the processes of creating, storing, and displaying family trees programmatically. It makes use of the MOAI SDK ([http://getmoai.com][moai]).


## Installation ##
 
 1. Install the MOAI SDK ([http://getmoai.com][moai])
 2. [Download][zip] the file repository.
 3. Open the folder containing the repository files.
 4. Change run.sh to suit your installation of MOAI
 5. Run run.sh

## Files/Folders ##

Assets - This folder contains all of the images used by the props that are created in main.lua

Attribution - This folder contains images that are used as splash-screens to satisfy the MOAI SDK license CPAL requirements. The contents of Attribution are Copyright Zipline Games and are subject to a license issued by Zipline Games.

Data - This folder holds the JSON file that stores data that is turned into a family tree. 

Library - This is where the interesting bits of the program are stored. The two most interesting files are:
 AdjacencyMatrix.lua - A module that deals with the creation and manipulation of adjacency matrices.
 
 Node.lua - A module that deals with the creation and manipulation of Nodes. Nodes are used in the process of displaying the family tree.

Tests - Contains unit tests that test the modules contained in Library.

main.lua - All of the MOAI specific code is stuffed here. The most interesting bit is createWarriorNodeProp().



## Copyright ##
Copyright (c) 2013 Paul Graham 

The MOAI SDK and the contents of the Attribution folder are Copyright Zipline Games and are subject to a license issued by Zipline Games. All material in this git repository Copyright Paul Graham is subject to a version of the MIT License.

See LICENSE for details.

[zip]: https://github.com/PaulWGraham/Warrior-Family-Tree/archive/master.zip
[moai]: http://getmoai.com