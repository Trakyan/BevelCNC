# BevelCNC
An Open Source CNC project looking to create a big machine on a small budget.

Note: The design is currently untested, I'm in the process of trying to print the parts. I'll be posting assembly videos once I have the machine built and set up.

Copy _lib into your OpenSCAD libraries folder, then use the BevelCNC OpenSCAD script to generate your STLs. 
The whole design is parametric, it should be able to generate all of the STLs you need from the information you provide under the "Machine specs" and "Hardware" sections.
For your final render to generate the STLs, make sure the "res" variable is set appropriately. "res" sets the length of the segments that make up the model, a small value means shorter segments and a more detailed model.

Feel free to ask if you have any questions!
