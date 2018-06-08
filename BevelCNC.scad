include <_lib/fillet_generator.scad>
include <_lib/bolt_sizes.scad>
include <_lib/math.scad>
include <_lib/colors.scad>

pi = 3.141592;

{//render details
tube_length = 500;
tube_color = color_metal;
corner_color = color_black;
perimeter_color = color_red;
center_color = color_black;
z_color = color_red;
}

res = 0.5;//3;//1.2;

{//machine specs   
wall_thick = 10;
min_thick = 5;
chamfer_angle = 45; //please don't change this I don't know why it's an option
fillet = 1.2;
clearance = 2;
tolerance = 0.3;
interference = 0.5;
break_edge = 0.5;

//larger rail seperation and z travel result in lower rigidity
z_rail_seperation = 5; //center to center distance. this will be automatically enlarged if it isn't large enough
z_travel = 50;
//taller carriage results in a more stable carriage due to a wider seperation between the bearings. It also requires a larger standoff for the Z plate, which makes things less rigid. Catch #22
z_carriage_height =  60;


bearing_angle = 120; //go nuts. 120 makes the three bearings evenly spaced radially. Don't get too close to 90 or the bearings wont have a "grip" on the rail and the carriage will fall off.
z_bearing_angle = 90; //90 or less, otherwise you run the risk of hitting your XY rails. 

//i don't recommend turning these off
bearing_cowlings = "true";
slide_underside_bridge = "true";
cutouts = "true"; //some cutouts to save material
slide_wing_braces = "true";

}

{//hardware
hardware = M5;
    
z_coupler_length = 40;
z_coupler_radius = 15;    
anti_backlash_spring_length = 15;
    
pulley = hardware[3];
{// pulley  
pulley_bore = pulley[2];
pulley_radius = pulley[1];
pulley_thick = pulley[0]; 
}
bearing = hardware[3];
{// bearing
bearing_bore = bearing[2]; 
bearing_radius = bearing[1];
bearing_thick = bearing[0]; 
}
nut = hardware[1];
{// nut
nut_thick = nut[0];
nut_radius = nut[1];
}

{// z drive
z_nut = hardware[1];
z_nut_thick = z_nut[0];
z_nut_radius = z_nut[1];
z_leadscrew = hardware[0];
z_leadscrew_radius = z_leadscrew[0];

z_bearing = hardware[3];    
z_bearing_bore = z_bearing[2]; 
z_bearing_radius = z_bearing[1];
z_bearing_thick = z_bearing[0]; 
}

bolt = hardware[0];   
{// bolt
bolt_radius = bolt[0];
bolt_head_thick = bolt[2];
bolt_head_radius = bolt[1];
}
washer = hardware[2];//washer thickness

motor = NEMA17;
motor_width = motor[0];
motor_length = motor[1];
motor_shaft_radius = motor[4];
motor_shaft_length = motor[5];
motor_key_depth = motor[6];
motor_key_length = motor[7];
motor_bolt_radius = motor[8];
motor_bolt_spacing = motor[2];

tube = 25.4/2;

}
{//derived specs
{//general
chamfer = bearing_radius-clearance-interference-(bolt_radius+tolerance+break_edge)-break_edge*2;
big_bevel = wall_thick/2;
bolt_bezel = bolt_radius+2*break_edge+chamfer;
bolt_head_bezel = bolt_head_radius+break_edge+min_thick+chamfer;
    
filleting_radius = fillet+chamfer;
bolt_head_plate = max(nut_radius, bolt_head_radius)+tolerance+max(clearance, break_edge+chamfer);
    
gear_width = 20;
motor_gear_teeth = 15;
pulley_gear_teeth = 25;
gear_helix = 2;
gear_twist = 1.5;
pressure_angle = 20;
}
{//cowlings
side_bearing_cowling = bearing_thick+2*washer+clearance;
top_bearing_cowling = bearing_radius+clearance+wall_thick;    
}
{//axis setup details
bearing_offset = tube+bearing_radius-interference;

axis_seperation = max(bearing_offset-bolt_head_plate+tube+wall_thick, 2*tube+clearance, 2*(tube+min_thick/2));
    //2*(tube+clearance)+min_thick; //max(2*bearing_offset-bolt_bezel-bolt_head_radius);
    
{//top mount stuff
top_mount_width = axis_seperation/2;
top_mount_height = bearing_offset+bolt_head_plate;

//with total clearance //has to be this so the center assembly can fit against each other.
top_mount_angle = atan((top_mount_width+(filleting_radius-chamfer))/(bearing_offset-(bolt_head_radius+tolerance)));
top_mount_diagonal = sqrt(pow(top_mount_width+(filleting_radius-chamfer),2)+pow(bearing_offset-(bolt_head_radius+tolerance),2));
slide_wing_thick = top_mount_diagonal*cos((bearing_angle-90)-top_mount_angle)-(filleting_radius-chamfer)-bearing_thick/2-washer;
}
}
{//perimeter clamp details
top_mount_extension = (bearing_thick/2+washer+slide_wing_thick)*sin(bearing_angle-90)+(bearing_offset-bolt_head_plate)*sin(180-bearing_angle); //might be ISSUE (bolt heads collide)
}


{//z_axis plate stuff
z_spacing = max( 2*(tube+2*bolt_bezel+z_bearing_radius), z_rail_seperation, 2*(tube+sqrt(2*pow(motor_width/2+clearance, 2))+0*3*chamfer) );
z_rail_offset = sqrt(pow(z_spacing, 2)/2);
z_kingpin_offset = [z_rail_offset+(axis_seperation-bearing_offset), (axis_seperation-bearing_offset)];
z_ring_offset = z_kingpin_offset+polar(bearing_offset+bolt_bezel+nut_radius/cos(30), -(180-bearing_angle));
z_nut_offset = (z_ring_offset[1]+z_ring_offset[0])/2-(bearing_thick/2+washer+nut_radius/cos(30));
z_leadscrew_bezel = (z_leadscrew_radius+clearance+min_thick);
z_plate_thick = 2*bolt_head_plate;
    
z_mount_thick = (bolt_head_plate+bearing_radius+clearance+wall_thick);
drive_offset = (z_kingpin_offset[0]-z_kingpin_offset[1])*cos(45);
    
z_carriage_thickness = (bearing_offset+bolt_head_plate)*sin(z_bearing_angle/2)-(bearing_thick/2+washer)*sin(z_bearing_angle/2);
horizontal_mount_hole_spacing = (z_spacing/2-( (bearing_offset+nut_radius)*cos(z_bearing_angle/2)+(bearing_thick/2+washer+wall_thick+nut_thick+clearance)*cos(90-z_bearing_angle/2)+min_thick ));
vertical_mount_hole_spacing = z_carriage_height/2-bolt_head_plate+bolt_head_plate*tan(22.5)-bolt_bezel;
}
{//slide details
top_bearing_seperation = (z_kingpin_offset[0]+tube+clearance+min_thick+clearance+bearing_radius)/2;

slide_length = top_bearing_seperation+bolt_head_plate;

wing_width = bearing_offset+max((bolt_head_plate+bolt_bezel*2), bearing_radius+clearance+wall_thick);
wing_cutout_depth = bearing_offset+bearing_radius+clearance-tube-clearance-chamfer-break_edge;
wing_cutout_width = (slide_length-z_mount_thick-wing_cutout_depth)*2;

top_mount_to_wing = (slide_wing_thick+bolt_head_thick+clearance+bearing_thick/2+washer)*sin(bearing_angle-90)+(bearing_offset-bolt_head_plate)*cos(bearing_angle-90);
}
{//top cowling details
    cowling_radius = top_bearing_cowling;
    cowling_depth = bolt_head_plate+cowling_radius*tan(22.5);
    cowling_bevel = top_mount_width-bearing_thick/2-washer-chamfer-chamfer;
    cowling_mini_bevel = top_bearing_cowling-cowling_bevel-bolt_head_plate;
}   
{//side cowling details
    min_cowling_clearance = ( (tube+clearance)-(bearing_offset+bearing_radius+clearance)*cos(180-bearing_angle) )/cos(bearing_angle-90)+bearing_thick/2+washer;
    cowling_clearance = max((bearing_thick+2*washer+nut_thick), min_cowling_clearance)-side_bearing_cowling+2*chamfer;
}
{//corner piece details
    horizontal_drive_axle_offset = top_mount_width+pulley_radius;
    vertical_drive_axle_offset = axis_seperation/2+bearing_offset+bolt_radius-(bearing_thick/2+washer);
    
    corner_bevel = big_bevel; 
    corner_socket_top = (vertical_drive_axle_offset-axis_seperation/2+washer+pulley_thick+washer+max(bolt_head_thick, nut_thick)+clearance);
    corner_socket_bottom = (tube+2*bolt_head_plate+corner_bevel);
    corner_socket_sides = 2*(tube+chamfer+min_thick+corner_bevel);
    
    corner_depth = max( 2*(horizontal_drive_axle_offset+bolt_bezel+bolt_head_plate+corner_bevel), (2*(corner_socket_sides/2+corner_bevel+2*chamfer+2*bolt_head_plate+corner_bevel)) ); 
    drive_motor_offset = corner_depth/2+motor_width/2;
    //corner_depth/2-corner_bevel-motor_bolt_radius-chamfer-min_thick+motor_bolt_spacing/2;
    
    foot_bolt_spacing_xy = 4*bolt_head_plate+corner_bevel-chamfer;
    foot_bolt_spacing = sqrt(2*pow(foot_bolt_spacing_xy, 2));
    
    drive_radius = sqrt( pow(horizontal_drive_axle_offset, 2) + pow(horizontal_drive_axle_offset+drive_motor_offset, 2) );   
    mm_per_tooth = 2*pi*drive_radius/(motor_gear_teeth+pulley_gear_teeth);
    //pr = mmpt*nt/pi/2+mmpt*nt/pi/2
}
{//Z plate mount stuff
wing_bolt_clearance = bearing_offset+bolt_head_plate;
top_bolt_clearance = bearing_offset-bolt_head_plate-0*bolt_head_radius;   
    
initial_clearance_x = wing_bolt_clearance/cos(bearing_angle-90);
secondary_clearance_x = top_bolt_clearance*tan(bearing_angle-90);
z_travel_clearance = ( z_travel+( z_carriage_height+2*(bearing_radius-bolt_head_plate) ) )/2-2*top_mount_width+z_plate_thick/2;
    
total_mount_clearance = [max(z_travel_clearance, initial_clearance_x+secondary_clearance_x), top_bolt_clearance];


}
{//underside bridge details
bridge_xy = [(wing_width-chamfer)*cos(bearing_angle-90)-(side_bearing_cowling+cowling_clearance-(bearing_thick/2+washer)-chamfer)*sin(bearing_angle-90), -((wing_width-chamfer)*sin(bearing_angle-90)+(side_bearing_cowling+cowling_clearance-(bearing_thick/2+washer)-chamfer)*cos(bearing_angle-90))];
    
x_brace_radius = bearing_offset+bearing_radius+clearance;
x_bottom_clearance = (x_brace_radius+chamfer)*cos(180-bearing_angle)+(side_bearing_cowling-(bearing_thick/2+washer)+cowling_clearance-chamfer)*cos(bearing_angle-90);
x_bridge_to_center = (x_brace_radius+chamfer)*sin(180-bearing_angle)-(side_bearing_cowling-(bearing_thick/2+washer)+cowling_clearance-chamfer)*sin(bearing_angle-90)-wall_thick;

clearance_ramp = cowling_clearance;
    
brace_radius = bearing_offset+bearing_radius+clearance;
bottom_clearance = (brace_radius+chamfer)*cos(180-bearing_angle)+(side_bearing_cowling-(bearing_thick/2+washer)+cowling_clearance-chamfer)*cos(bearing_angle-90);
bridge_to_center = (brace_radius+chamfer)*sin(180-bearing_angle)-(side_bearing_cowling-(bearing_thick/2+washer)+cowling_clearance-chamfer)*sin(bearing_angle-90)-wall_thick;

clearance_ramp = cowling_clearance;

//details for the brace block
brace_width = wing_width-(bearing_offset+bearing_radius+clearance);
brace_length = slide_length+chamfer-(wing_cutout_width/2+wing_cutout_depth);
bridge_taper_length = brace_length+(wing_width-bearing_offset-bearing_radius-clearance)-chamfer*2;

bridge_thickness = (brace_width)*sin(bearing_angle-90)+chamfer*cos(30);//2*chamfer+min_thick;
    
bolt_clearance_width = 2*( (bearing_offset+bolt_head_radius+clearance)*cos(bearing_angle-90) - (bearing_thick/2+washer)*cos(bearing_angle-90) );
}
}
{//bearing slides (XY and Center)
module side_cowling_cutouts(edge_chamfer=chamfer, depth=side_bearing_cowling+chamfer)
{
    bevel_for_bearing = (bearing_radius+clearance)*tan(22.5);
    for ( i = [ 0 : 1 ] ) 
    mirror([i, 0, 0]) {
        //cutouts that house the bearings
        hull() {
            
            cowling_space = bearing_offset+bearing_radius+clearance;
            for ( j = [ 0 : 1 ] )
            translate([slide_length+chamfer+(edge_chamfer-chamfer)-(bearing_radius+clearance+bevel_for_bearing+chamfer+2*(edge_chamfer-chamfer))/2-j*wing_width, (cowling_space+2*chamfer+(edge_chamfer-chamfer))/2-2*chamfer-j*wing_width, -depth+bearing_thick/2+washer])
            cube_c([bearing_radius+clearance+bevel_for_bearing+chamfer+2*(edge_chamfer-chamfer), cowling_space+2*chamfer+(edge_chamfer-chamfer), depth], chamfer=edge_chamfer);
        }
        
        
        //inner cutout, on the side with the tube
        inner_cutout = tube+clearance+(break_edge+chamfer)+chamfer+(edge_chamfer-chamfer);
        
        translate([0, inner_cutout/2, -depth+bearing_thick/2+washer])
            cube_c([2*(slide_length+chamfer+(edge_chamfer-chamfer)), inner_cutout, depth], chamfer=edge_chamfer);
        
        //front and back edge bevels
        translate([slide_length, (bearing_offset+bearing_radius+clearance+4*chamfer)/2-3*chamfer, bearing_thick/2+washer-side_bearing_cowling-2*chamfer])
        cube_c([4*chamfer, bearing_offset+bearing_radius+clearance+4*chamfer, side_bearing_cowling+3*chamfer], chamfer=2*chamfer);
        
        translate([slide_length, bearing_offset+bearing_radius+clearance, -4*chamfer+bearing_thick/2+washer-side_bearing_cowling])
        cube_c([6*chamfer, 6*chamfer, 6*chamfer], chamfer=3*chamfer);
    }
}   
module wing_cutouts(depth=0)
{    
    {//middle cutout thing
        translate([0, (wing_width+2*wing_cutout_width)/2+(wing_width-wing_cutout_depth), bearing_thick/2+washer+chamfer-(bearing_cowlings == "true" ? side_bearing_cowling:0)-wing_cutout_width-depth])
        cube_c_cutout([3*wing_cutout_width, wing_width+2*wing_cutout_width, slide_wing_thick+side_bearing_cowling+2*wing_cutout_width-2*chamfer+depth], chamfer=wing_cutout_width);
    }
            
    {//cutout bevel for some clearance in the center assembly
    translate([slide_length, wing_bolt_clearance+3*chamfer, slide_wing_thick+bearing_thick/2+washer])
    rotate([-45, 0, 0])
    translate([0, wing_width/2-chamfer, slide_wing_thick])
    rotate([0, -90, 0])
    cube_c([2*slide_wing_thick, wing_width, 2*slide_length], chamfer=-chamfer);
    }
    {//cutout for the bearings to go in  
        side_cowling_cutouts();
        translate([0, 0, 2*chamfer-side_bearing_cowling])
        side_cowling_cutouts(3*chamfer, 6*chamfer);
    }
}
module top_bearing_cowling()
{   
    hull(){
        translate([0, (bolt_head_plate+top_bearing_cowling-cowling_bevel)/2-bolt_head_plate, 0])
        cube_c([2*top_mount_width, bolt_head_plate+top_bearing_cowling-cowling_bevel, bolt_head_plate+cowling_depth]);
        
        translate([0, (top_bearing_cowling+bolt_head_plate)/2-bolt_head_plate, 0])
        cube_c([2*(top_mount_width-cowling_bevel), top_bearing_cowling+bolt_head_plate, bolt_head_plate+cowling_depth]);
        
        cube_c([2*top_mount_width, 2*bolt_head_plate, bolt_head_plate+cowling_depth+cowling_mini_bevel]);
        
        cube_c([2*(top_mount_width-cowling_bevel), 2*bolt_head_plate, cowling_depth+cowling_radius]);
    }
}
module underside_brace_block(pos, scale_factor=1, brace_width=brace_width, brace_length=brace_length, bridge_taper_length=bridge_taper_length)
{  
    bevel = (pos == "center" ? 0:big_bevel);
    
    offset_radius = wing_width-(brace_width-bevel)-bevel;
    
    hull() {
        translate([slide_length-(brace_length)/2, offset_radius+scale_factor*(brace_width-bevel)/2, bearing_thick/2+washer-side_bearing_cowling])
        cube_c([brace_length, scale_factor*(brace_width-bevel), 2*chamfer]);
        
        translate([slide_length-(brace_length-bevel)/2-bevel, offset_radius+scale_factor*(brace_width)/2, bearing_thick/2+washer-side_bearing_cowling])
        cube_c([(brace_length-bevel), scale_factor*brace_width, 2*chamfer]);
        
        translate([slide_length-bridge_taper_length/2, bearing_offset+bearing_radius+clearance+chamfer, bearing_thick/2+washer-side_bearing_cowling])
        cube_c([bridge_taper_length, 2*chamfer, 2*chamfer]);
    }
}
module underside_brace(pos)
{
    scaling_factor = bridge_thickness/brace_width;
    
    
        
    {//initial ramp from wing to clear the bearing/nut on the bottom of wing
    difference() {
        for ( i = [ 0 : 1 ] )
        mirror([i, 0, 0])
        hull() {
            for ( j = [ 0 : 1 ] )
            for ( k = [ 0 : 1 ] )
            translate([-k*j*clearance_ramp, 0, -j*clearance_ramp])
            underside_brace_block(i == 1 ? pos:"perimeter");
        }
        
        translate([0, brace_radius-2*chamfer+3*chamfer, bearing_thick/2+washer-side_bearing_cowling-clearance_ramp-3*chamfer])
        cube_c([6*slide_length, 4*chamfer, 4*chamfer]);
    }
    
    }
    {//rotate to get it vertical
    for ( i = [ 0 : 1 ] )
    mirror([i, 0, 0])
    hull() {
        for ( j = [ 0 : 1 ] ) 
        for ( k = [ 0 : 1 ] )
        translate([-k*clearance_ramp, brace_radius+chamfer, -side_bearing_cowling+(bearing_thick/2+washer)+chamfer-clearance_ramp])
        difference() {
            rotate([-j*(180-bearing_angle), 0, 0])
            translate([0, -brace_radius-chamfer, side_bearing_cowling-(bearing_thick/2+washer)-chamfer])
            underside_brace_block(i == 1 ? pos:"perimeter", j == 1 ? scaling_factor:1);
            
            rotate([180+j*(bearing_angle-0), 0, 0]) {
                cube_c([6*slide_length, 6*chamfer, 2*chamfer]);
                rotate([j*90, 0, 0])
                cube_c([6*slide_length, 6*chamfer, 2*chamfer]);
            }
        }
    }
    }
    {//for final bridge to a center column
    difference() {
        for ( i = [ 0 : 1 ] )
        mirror([i, 0, 0])
        hull() {
            for ( j = [ 0 : 1 ] )
            for ( k = [ 0 : 1 ] )
            translate([-k*clearance_ramp, brace_radius+chamfer, -side_bearing_cowling+(bearing_thick/2+washer)+chamfer-clearance_ramp])
            rotate([-(180-bearing_angle), 0, 0])
            translate([-j*k*bridge_to_center-k*(j-1)*chamfer, -brace_radius-chamfer, side_bearing_cowling-(bearing_thick/2+washer)-chamfer-j*bridge_to_center-k*(j-1)*chamfer])
            underside_brace_block(i == 1 ? pos:"perimeter", scaling_factor);
        }
        
        //trims for the inside corner
        translate([0, brace_radius+3*chamfer, bearing_thick/2+washer-side_bearing_cowling-clearance_ramp])
        cube_c([6*slide_length, 4*chamfer, 2*(wing_width-brace_radius)]);
        
        
        //trims for the outside corner
        translate([0, brace_radius+chamfer, bearing_thick/2+washer-side_bearing_cowling-clearance_ramp+chamfer])
        rotate([-2*(bearing_angle-90), 0, 0])
        translate([0, (wing_width-brace_radius-chamfer), 0])
        rotate([bearing_angle-90, 0, 0])
        translate([0, 2*chamfer, -(wing_width-brace_radius)])
        cube_c([6*slide_length, 4*chamfer, 2*(wing_width-brace_radius)]);   
    }
    
    }
    {//center column
    hull() {
        center_comp = pos == "center" ? big_bevel:0;
        
        rotate([bearing_angle-90, 0, 0])
        translate([0, 0, chamfer-bottom_clearance-(scaling_factor*(wing_width-brace_radius-big_bevel))])
        cube_c([2*(slide_length), 2*(wall_thick+chamfer), scaling_factor*(wing_width-brace_radius-big_bevel)]);
        
        
        rotate([bearing_angle-90, 0, 0])
        translate([-center_comp/2, 0, chamfer-bottom_clearance-(bridge_thickness+0*(wing_width-brace_radius))])
        cube_c([2*(slide_length-big_bevel+center_comp/2), 2*(wall_thick+chamfer), bridge_thickness+0*(wing_width-brace_radius)]);
    }
    }

}
module slide_wing_braces()
{
    fillet_offset = (fillet+chamfer)/tan(bearing_angle/2);
    bevel =  min(bolt_head_plate+(bolt_head_radius+tolerance)+fillet_offset-chamfer, wing_width-wing_cutout_depth-chamfer);
    length = 2*(top_bearing_seperation-bolt_head_plate);
    
    translate([top_mount_width-chamfer, bearing_offset-(bolt_head_radius+tolerance+fillet_offset), 0])
    
    hull() {
        for ( i = [ 0 : 1 ] )
        rotate([0, 0, -i*bearing_angle])
        mirror([i, 0, 0])
        difference() {
            hull() {
                    translate([0, 0, -length/2])
                    cube_c([2*chamfer, 2*chamfer, length]);
                    
                    translate([0, bevel, -(length-2*bevel)/2])
                    cube_c([2*chamfer, 2*chamfer, length-2*bevel]);
            }
            rotate([0, 0, -bearing_angle/2])
            translate([0, 0, -length/2])
            cube([2*chamfer, 2*chamfer, length]);
        }
    }
}
module bearing_slide_wings(pos)
{  
    bevel = big_bevel;//wing_width-bevel_offset;
    //c == 0 makes the slide wing, c == 1 makes the outer edge of the cowling
    
    difference() {
        width = wing_width;
        thickness = slide_wing_thick+side_bearing_cowling;
        length = pos == "center" ? slide_length:(slide_length-bevel);

        translate([0, 0, bearing_thick/2+washer-side_bearing_cowling]) 
                hull() {
                    //the inner part of the wing
                    translate([0, wing_width-(width+chamfer+bevel)/2, 0])
                    cube_c([2*slide_length, width-bevel+chamfer, thickness]);
                    
                    //the outer block of the wing
                    translate([slide_length-(slide_length-bevel+length)/2-bevel, wing_width-(width+chamfer)/2, 0])
                    cube_c([(slide_length-bevel)+length, width+chamfer, thickness]);
                }
                
        
        
        //bolt hole cutouts
        for ( i = [ 0 : 1 ] )
            mirror([i, 0, 0])
            translate([top_bearing_seperation, bearing_offset, bearing_thick/2+washer-break_edge])
            cylinder_c(slide_wing_thick+2*break_edge, bolt_radius+tolerance, chamfer=-2*break_edge);
        
        //cutouts for material saving
        if ( cutouts == "true" ) {
            wing_cutouts();
        }
    }
}

module z_plate_mounts()
{
    //end bolts
    for ( i = [ 0 : 1 ] )
    mirror([i, 0, 0])
    difference() {
        hull() {
            translate([i*2*top_mount_width, 0, 0])
            translate(total_mount_clearance)
            translate([z_plate_thick/2, -bolt_head_plate, -slide_length])
            cube_c([z_plate_thick, 2*bolt_head_plate, z_mount_thick]);
            
                   
            
            translate([bridge_xy[0], bridge_xy[1], -slide_length])
            rotate([0, 0, -(bearing_angle-90)])
            cube_c([2*chamfer, 2*chamfer, z_mount_thick]);
            
            translate([((total_mount_clearance[0]+z_plate_thick)-(total_mount_clearance[1]-bolt_head_plate-bridge_xy[1])*sin(bearing_angle-90))+0*i*2*top_mount_width, bridge_xy[1], -slide_length])
            rotate([0, 0, -(bearing_angle-90)])
            cube_c([2*chamfer, 2*chamfer, z_mount_thick]);
            
            rotate([0, 0, -(bearing_angle-90)])
            translate([bearing_offset+bolt_head_plate+chamfer, bearing_thick/2+washer+slide_wing_thick-chamfer, -slide_length])
            cube_c([2*chamfer, 2*chamfer, z_mount_thick]);
        }
        
        
        translate([i*2*top_mount_width+z_plate_thick/2, -bolt_head_plate, -slide_length-break_edge])
        translate(total_mount_clearance)
        cylinder_c(z_mount_thick+2*break_edge, bolt_radius+tolerance, chamfer=-2*break_edge);
    }

    
    {//kingpin support
    //to topmount
    hull() {
        translate([total_mount_clearance[0]/2, bearing_offset, slide_length-2*bolt_head_plate])
        cube_c([total_mount_clearance[0], 2*bolt_head_plate, 2*bolt_head_plate]);
        
        translate([chamfer, bearing_offset, slide_length-2*bolt_head_plate-(total_mount_clearance[0]-2*chamfer)])
        cube_c([2*chamfer, 2*bolt_head_plate, 2*bolt_head_plate]);
    }
    //to wing    
    bevel_to_wing = min(wing_width-big_bevel, total_mount_clearance[0]);
    
    hull() 
    {
        for ( i = [ 0 : 1 ] ) {
            translate([0, bearing_offset-bolt_head_plate+chamfer, slide_length-2*bolt_head_plate])
            rotate([0, 0, -i*(bearing_angle-90)])
            translate([bevel_to_wing/2, 0, 0])
            cube_c([bevel_to_wing, 2*chamfer, 2*bolt_head_plate]);
            
            translate([0, bearing_offset-bolt_head_plate+chamfer, slide_length-2*bolt_head_plate-(bevel_to_wing-top_mount_width)])
            rotate([0, 0, -i*(bearing_angle-90)])
            translate([top_mount_width/2, 0, 0])
            cube_c([top_mount_width, 2*chamfer, 2*bolt_head_plate]);
        }
        
    }
    }
}
module perimeter_slide_clamps()
{
    upper_corner = axis_seperation+tube+bolt_bezel+bolt_head_bezel;
    //SORT THIS OUT, fix bevel so it gives room for bearing, also so it leaves room for clamping bolt
    bevel = min(upper_corner-bearing_offset-bearing_radius-clearance-3*chamfer, slide_length-2*wall_thick); //min(slide_length-tube, 3*(upper_corner-top_mount_height)*2/3);
        
    clamp_width = (top_mount_width-bearing_thick/2-washer);
    
    lower_corner = upper_corner-bevel;
    
    difference(){
        hull(){
            //lower corner
            translate([0, (lower_corner-top_mount_height-2*chamfer)/2+top_mount_height, -slide_length])
            cube_c([top_mount_width*2, lower_corner-top_mount_height+2*chamfer, 2*(slide_length)]);
            
            //upper corner
            translate([0, (upper_corner-top_mount_height-2*chamfer)/2+top_mount_height, -(slide_length-bevel)])
            cube_c([top_mount_width*2, upper_corner-top_mount_height+2*chamfer, 2*(slide_length-bevel)]);
        }
        
        //subtracted items start here
        
        //tube and top bearing bolt cutouts
        translate([-top_mount_width, 0, 0])
        rotate([0, 90, 0])
        {
            //top bearing bolt holes recut
            for ( k = [ 0 : 1 ] )
            mirror([k, 0, 0])
            translate([top_bearing_seperation, bearing_offset, -break_edge])
            cylinder_c(2*top_mount_width+2*chamfer, bolt_radius+tolerance, chamfer=-2*break_edge);
            
            //tube cutout
            translate([0, axis_seperation, -chamfer])
            cylinder_c(2*top_mount_width+2*chamfer, tube, chamfer=-2*chamfer);
        }
        
        //clamp splits
        for ( i = [ 0 : 1 ] ) 
        mirror([i, 0, 0])
        translate([(min_thick+chamfer), axis_seperation+tube+bolt_bezel+bolt_head_bezel, 0])
        rotate([0, 45, 0])
        translate([top_mount_width, 0, top_mount_width])
        rotate([90, 0, 0])
        cube_c([2*top_mount_width, 2*top_mount_width, tube+bolt_bezel+bolt_head_bezel], bottom_chamfer=-chamfer, top_chamfer=0);
            
        
        //bearing cutout
        translate([0, bearing_offset, top_bearing_seperation-(bearing_radius+clearance)])
        cube_c([bearing_thick+2*washer, 2*(bearing_radius+clearance), 2*(bearing_radius+clearance)], chamfer=chamfer);
                
        //bearing cutouts chamfer
        translate([0, tube+clearance, slide_length])
        rotate([-90, 0, 0])
        cube_c([2*(bearing_thick/2+washer+chamfer), 4*chamfer, bearing_offset+bearing_radius+clearance-tube-clearance+chamfer], chamfer=2*chamfer, bottom_chamfer=-2*chamfer);
        
    
        
        //clamp bolt holes
        for ( k = [ 0 : 1 ] )
        mirror([k, 0, 0])
        for ( m = [ 0 : 1 ] )
        mirror([0, 0, m])
        {
            translate([top_mount_width-bolt_head_bezel, axis_seperation+tube+bolt_bezel, 0])
            cylinder_c(slide_length, bolt_radius+tolerance, chamfer=-break_edge-tolerance);
            
            translate([top_mount_width-bolt_head_bezel, axis_seperation+tube+bolt_bezel, tube+wall_thick-nut_thick/2])
            cylinder_c(slide_length, m == 1 ? (nut_radius/cos(30)+tolerance):(bolt_head_radius+tolerance), chamfer=m == 1 ? (nut_radius/cos(30)+tolerance):(bolt_head_radius+tolerance), faces=m == 1 ? 6:0);
        }    
        
    }
}
module bearing_slide_blank(pos)
{
    {//slide wings
    for ( i = [ 0 : 1 ] )
    mirror([i, 0, 0])
    {
        brace_length = 2*(top_bearing_seperation-z_nut_offset-z_leadscrew_bezel);//2*(top_bearing_seperation-(bolt_head_plate+clearance)-((bolt_head_plate+clearance)*tan(45/2)+bolt_head_plate-chamfer)+2*(bolt_head_plate+filleting_radius));
        
        rotate([0, 0, (bearing_angle)])
        rotate([0, 90, 0])
        bearing_slide_wings(pos);
       
        //slide wing braces
            if ( slide_wing_braces == "true" )
            slide_wing_braces();
    }
    }
    {//tube casing    
    translate([0, 0, -slide_length])
    rotate([0, 0, (180-2*(bearing_angle-90))/2])
    cylinder_c(2*slide_length, slide_wing_thick+bearing_thick/2+washer, deg=2*(bearing_angle-90), res=circle_res_correction(slide_wing_thick+bearing_thick/2+washer));
    }
    {//top mount
    translate([0, top_mount_height-bolt_head_plate-filleting_radius/2, -slide_length])
    cube_c([2*top_mount_width, 2*bolt_head_plate+filleting_radius, 2*slide_length]);
    }
    {//top mount fillet
    top_mount_fillet = filleting_radius;
    extra_shift = (top_mount_width+top_mount_fillet-chamfer-(slide_wing_thick+bearing_thick/2+washer+top_mount_fillet-chamfer)*sin(bearing_angle-90))/cos(bearing_angle-90);
    
    for ( i = [ 0 : 1 ] )
    mirror([i, 0, 0])
    rotate([0, 0, -(bearing_angle-90)])
    translate([extra_shift, slide_wing_thick+bearing_thick/2+washer+top_mount_fillet-chamfer, -slide_length])
    rotate([0, 0, bearing_angle+90])
    cylinder_c_internal(2*slide_length, top_mount_fillet-chamfer, thick=2*chamfer, deg=180-bearing_angle, res=res);
    }
    {//cowlings for top bearings
        for ( i = [ 0 : 1 ] )
        mirror([0, 0, i])
        translate([0, bearing_offset, -slide_length])
        top_bearing_cowling();
    }
    {//z assembly mount
    if ( pos == "center" )
        mirror([0, 0, 1])
        z_plate_mounts();
    }
    {//underside bridge
        for ( i = [ 0 : 1 ] )
        mirror([i, 0, 0])
        rotate([0, 0, (bearing_angle)])
        rotate([0, 90, 0])
        underside_brace(pos);
    }
}

module bearing_slide_cutout(pos)
{
    {//tube cutout
    translate([0, 0, -slide_length-chamfer])
    {
        cylinder_c(2*(slide_length+chamfer), tube+clearance, chamfer=-2*chamfer);
        
        underside_cut = bearing_thick/2+washer+2*chamfer;
        angle = 2*atan(underside_cut/(tube+clearance-(filleting_radius-chamfer)));
        
        poly_cylinder_c(
        [
        polar(tube+clearance-(filleting_radius-chamfer), angle),
        polar(tube+clearance-(filleting_radius-chamfer), -angle),
        [underside_cut, tube+clearance-(filleting_radius-chamfer), 0],
        [-underside_cut, tube+clearance-(filleting_radius-chamfer), 0]
        ],
        2*(slide_length+chamfer), filleting_radius-chamfer, chamfer=2*chamfer, res=circle_res_correction(filleting_radius+chamfer));
    }
    }   
    {//tube cutout fillet
    fillet_angle = acos((bearing_thick/2+washer+break_edge+chamfer)/(tube+clearance+break_edge+chamfer));

    for ( i = [ 0 : 1 ] )
    mirror([i, 0, 0])
    translate([0, 0, -slide_length-break_edge])
    translate(polar(tube+clearance+chamfer+break_edge, -bearing_angle+(90-fillet_angle)))
    rotate([0, 0, bearing_angle-180])
    cylinder_c_internal(2*slide_length+2*break_edge, break_edge+chamfer, chamfer=-chamfer-break_edge, thick=3*(break_edge+chamfer), deg=bearing_angle/2);
    }
    {//non cowling bearing cutouts
    if ( ( bearing_cowlings != "true" ) || ( pos == "perimeter" ) )
    for ( i = [ 0 : 1 ] )
    mirror([0, 0, i]) {
        {//bearing cutouts 
        translate([0, tube+clearance, top_bearing_seperation])
        rotate([-90, 0, 0])
        cube_c_cutout([bearing_thick+2*washer, 2*(bearing_radius+clearance), top_mount_height-(tube+clearance)], chamfer=chamfer);
        }
        {//bearing cutouts chamfer
        translate([0, tube+clearance, slide_length])
        rotate([-90, 0, 0])
        cube_c([2*(bearing_thick/2+washer+chamfer), 4*chamfer, top_mount_height-(tube+clearance)+(pos == "perimeter" ? (2*chamfer):0)], chamfer=2*chamfer, bottom_chamfer=-2*chamfer, top_chamfer=pos == "perimeter" ? -chamfer:(-2*chamfer));
        }
    }
    
        
    }
    {//cowling bearing cutouts
    if ( ( bearing_cowlings == "true" ) && ( pos != "perimeter" ) ) 
    for ( i = [ 0 : 1 ] )
    mirror([0, 0, i]){
        {//bearing cutouts
        translate([0, tube+clearance, top_bearing_seperation])
        rotate([-90, 0, 0])
        cube_c([2*(bearing_thick/2+washer), 2*(bearing_radius+clearance), bearing_offset+bearing_radius+clearance-tube-clearance], bottom_chamfer=-chamfer);
        }
        {//bearing cutouts chamfer
        translate([0, tube+clearance, slide_length])
        rotate([-90, 0, 0])
        cube_c([2*(bearing_thick/2+washer+chamfer), 4*chamfer, bearing_offset+bearing_radius+clearance-tube-clearance+chamfer], chamfer=2*chamfer, bottom_chamfer=-2*chamfer);
        }
    }
    }
    {//top bearing bolt holes
    for ( i = [ 0 : 1 ] )    
    mirror([0, 0, i])
    for ( j = [ 0 : 1 ] )
    mirror([j, 0, 0])
    {
        hole_depth = ( ( (i == 1) && (j == 0) && (pos == "center") ) ? (total_mount_clearance[0]):(top_mount_width) ) - (bearing_thick/2+washer)+2*break_edge;//( ( (i == 0) && (j == 1) && (pos == "center") ) ? (2*top_mount_width+top_mount_to_wing):( ( (pos == "center") && (j == 0) ) ? (top_mount_to_wing):(top_mount_width) ) )-(bearing_thick/2+washer)+2*break_edge;
        
        translate([bearing_thick/2+washer-break_edge, bearing_offset, top_bearing_seperation])
        rotate([0, 90, 0])
        cylinder_c(hole_depth, bolt_radius+tolerance, chamfer=-2*break_edge);
    }
    }
    {//slot for the wing nut (in kingpin brace)
    if ( pos == "center" )
    rotate([0, 0, -(bearing_angle-90)]) {
        hull() {
            for ( i = [ 0 : 1 ] )    
            translate([bearing_offset+i*wing_width, bearing_thick/2+washer+slide_wing_thick, -top_bearing_seperation])
            rotate([-90, 0, 0])
            cylinder_c(nut_thick+clearance, nut_radius/cos(30)+tolerance, chamfer=break_edge, faces=6);
        }
        translate([bearing_offset, bearing_thick/2+washer-break_edge, -top_bearing_seperation])
        rotate([-90, 0, 0])
        cylinder_c(slide_wing_thick+2*break_edge, bolt_radius+tolerance, chamfer=-2*break_edge);
    }
    }
    {//top tube cutout (for perimeter slides)
    if ( pos == "perimeter" ) {
        translate([-top_mount_width, axis_seperation, 0])
        rotate([0, 90, 0])
        cylinder_c(2*top_mount_width, tube, chamfer=-chamfer);    
        
        for ( i = [ 0 : 1 ] )
        mirror([i, 0, 0])
        translate([top_mount_width-chamfer, axis_seperation, 0])
        rotate([0, 90, 0])
        cylinder_c(wing_width, tube+chamfer);
    }
    }
    {//z rail cutout (for center slides)
    //bearing cutout
    hull() {
        translate([(bearing_offset+wing_width), 0, -top_bearing_seperation])
        rotate([0, -90, 0]) 
        for ( i = [ 0 : 1 ] )
        mirror([i, -i, 0])
        translate([z_kingpin_offset[0], axis_seperation, 0])
        for ( j = [ -1 : 2 : 1 ] )
        rotate([0, 0, j*z_bearing_angle/2+45])
        translate([0, bearing_offset, 0])
        cube_c([bearing_thick+washer+bolt_head_thick, 2*(bearing_radius+clearance), 2*(bearing_offset+wing_width)]);
    }
    //rail cutout
    if ( pos == "center" )
    hull() {
        cutout_radius = tube+clearance;
        
        translate([-(bearing_offset+wing_width), axis_seperation, z_kingpin_offset[0]-top_bearing_seperation])
        rotate([0, 90, 0]) 
        rotate([0, 0, 360/16])
        cylinder_c(2*(bearing_offset+wing_width), cutout_radius/cos(22.5), faces=8);
        
        
        translate([-(bearing_offset+wing_width), 2*top_mount_height, z_kingpin_offset[0]-top_bearing_seperation])
        rotate([0, 90, 0])
        rotate([0, 0, 360/16])
        cylinder_c(2*(bearing_offset+wing_width), cutout_radius/cos(22.5), faces=8);
        
        translate([-(bearing_offset+wing_width), 2*top_mount_height, z_kingpin_offset[0]-top_bearing_seperation-2*top_mount_height+axis_seperation])
        rotate([0, 90, 0])
        rotate([0, 0, 360/16])
        cylinder_c(2*(bearing_offset+wing_width), cutout_radius/cos(22.5), faces=8);
        
    }
    }
    {//bolt head/allen key cutouts in underside brace for wing bearing bolts
        for ( i = [ 0 : 1 ] )
        mirror([0, 0, i]) {
            
            /*
            translate([0, chamfer-bottom_clearance, slide_length+chamfer-(2*bolt_head_plate+chamfer)/2])
            rotate([90, 0, 0])
            cube_c([bolt_clearance_width, 2*bolt_head_plate+chamfer, bridge_thickness], chamfer=-chamfer);
            */
            //cutout
            hull()
            {
                translate([0, 2*chamfer-bottom_clearance, slide_length+chamfer-(2*bolt_head_plate+chamfer)/2])
            rotate([90, 0, 0])
            cube_c([bolt_clearance_width, 2*bolt_head_plate+chamfer, bridge_thickness+2*chamfer]);
                
                translate([0, 2*chamfer-bottom_clearance, slide_length+chamfer-(2*bolt_head_plate+chamfer)/2-(bolt_clearance_width-3*chamfer)/2])
            rotate([90, 0, 0])
            cube_c([3*chamfer, 2*bolt_head_plate+chamfer, bridge_thickness+2*chamfer]);
            }
            
            //face beveling
            for ( i = [ 0 : 1 ] )
            translate([0, -i*bridge_thickness, 0])
            hull()
            {
                translate([0, 2*chamfer-bottom_clearance, slide_length+chamfer-(2*bolt_head_plate+chamfer)/2])
            rotate([90, 0, 0])
            cube_c([bolt_clearance_width+2*chamfer, 2*bolt_head_plate+chamfer, 2*chamfer]);
                
                translate([0, 2*chamfer-bottom_clearance, slide_length+chamfer-(2*bolt_head_plate+chamfer)/2-(bolt_clearance_width-3*chamfer)/2-chamfer])
            rotate([90, 0, 0])
            cube_c([3*chamfer, 2*bolt_head_plate+chamfer, 2*chamfer]);
            }
            //end beveling
            translate([0, chamfer-bottom_clearance, slide_length+(2*chamfer)/2-1*chamfer])
            rotate([90, 0, 0])
            cube_c([bolt_clearance_width+2*chamfer, 2*chamfer, bridge_thickness], chamfer=-chamfer);
        }
        
    }
}
module bearing_slide(pos)
{
    mirror([0, 0, 1])
    difference(){
        bearing_slide_blank(pos);
        bearing_slide_cutout(pos);
    }
    
    //tube clamp
    if ( pos == "perimeter" )
        perimeter_slide_clamps();   

    
    *translate([-bearing_thick/2-1*washer, bearing_offset, top_bearing_seperation])
    rotate([0, 90, 0])
    cylinder_c(bearing_thick+1*2*washer, bearing_radius+clearance, res=circle_res_correction(bearing_radius+clearance));
    //
    *translate([60, bearing_offset, -top_bearing_seperation])
    rotate([0, 90, 0])
       cylinder_c(15, bolt_head_plate, res=circle_res_correction(bolt_head_plate));    
        
    //
    *translate([-bearing_thick/2-washer, bearing_offset, slide_length-bolt_head_plate])
    rotate([0, 90, 0])
    cylinder_c(bearing_thick+2*washer, bearing_radius+clearance);
    
    *rotate([0, 0, -bearing_angle])
    translate([-bearing_thick/2-washer, bearing_offset, 0])
    rotate([0, 90, 0])
    cylinder_c(bearing_thick+2*washer, bearing_radius);
    
    *cylinder_c(slide_length*2, tube);
    
}
}
{//z_axis stuff
module z_motor_mount()
{
    motor_bezel = big_bevel;
    
    translate(z_kingpin_offset)
    rotate([0, 0, 45])
    translate([0, z_spacing/2, 0])
    hull()
    for ( i = [ -1 : 2 : 1 ] )
    translate([0, i*motor_bezel/2, 0])
    rotate([0, 0, 45])
    cube_c([motor_width+2*motor_bezel, motor_width+2*motor_bezel, z_plate_thick]);
    
    motor_bolt_diagonal = sqrt(2*pow(motor_bolt_spacing/2,2));
    motor_bolt_surround = motor_bolt_diagonal-z_bearing_radius-2*chamfer;
    standoff_width = ((motor_bezel+(motor_width-motor_bolt_spacing)/2-chamfer)/cos(45)+motor_bolt_surround+motor_bezel/2)/cos(45)-2*motor_bezel/2*cos(45)-chamfer;
    
    for ( m = [ -1 : 2 : 1 ] )
    hull()
    for ( i = [ 0 : 1 ] )
    mirror([i, -i, 0])
    translate(z_kingpin_offset)
    rotate([0, 0, 45])
    translate([0, z_spacing/2+m*motor_bezel/2, 0])
    rotate([0, 0, -45])
    for ( j = [ 0 : 1 ] )
    translate([m*(chamfer-(motor_width/2+motor_bezel)), m*(chamfer-(motor_width/2+motor_bezel)+j*standoff_width), 0])
    cube_c([2*chamfer, 2*chamfer, z_plate_thick+z_coupler_length+3*chamfer]);
}
module z_plate_cutouts(motor_mount)
{
    translate([0, 0, -chamfer])
    for ( i = [ 0 : 1 ] )
    mirror([i,-i,0]) {
        //z rail holes
        translate([z_kingpin_offset[0], z_kingpin_offset[1], 0])
        cylinder_c(z_plate_thick+2*chamfer, tube+tolerance, chamfer=-2*chamfer);
        
        //kingpin hole
        cylinder_c(z_plate_thick+2*chamfer, bolt_radius+tolerance, chamfer=-2*chamfer);
        
        {//leadscrew bearing and hole
        //leadscrew bearing
        translate([z_kingpin_offset[1], z_kingpin_offset[1], 0])
        rotate([0, 0, -45])
        translate([0, drive_offset, z_plate_thick+chamfer-z_bearing_thick])
        cylinder_c(z_bearing_thick+chamfer, z_bearing_radius+tolerance, chamfer1=chamfer, chamfer2=-2*chamfer);
        //leadscrew clearance hole
        translate([z_kingpin_offset[1], z_kingpin_offset[1], 0])
        rotate([0, 0, -45])
        translate([0, drive_offset, 0])
        cylinder_c(z_plate_thick-z_bearing_thick+2*chamfer, z_leadscrew_radius+clearance, chamfer=-2*chamfer);
        }
        
        //clamping slit
        translate(z_kingpin_offset)
        rotate([0, 0, -45])
        translate([-z_spacing/2, 0, chamfer])
        cube_c([z_spacing, max(2*chamfer, clearance), z_plate_thick], chamfer=-chamfer);
        
        //z rail clamping
        translate(z_kingpin_offset)
        rotate([0, 0, -45])
        translate([-(tube+bolt_bezel), 0, z_plate_thick/2+chamfer]) {
            
            translate([0, chamfer-max(2*chamfer, clearance)/2, 0])
            rotate([90, 0, 0])
            cylinder_c(wall_thick+tube+chamfer+break_edge-max(2*chamfer, clearance)/2-nut_thick-clearance, bolt_radius+tolerance, chamfer1=-2*chamfer, chamfer2=-2*break_edge);
            
            translate([0, -(wall_thick+tube-max(2*chamfer, clearance)/2+chamfer-(nut_thick+clearance)), 0])
            rotate([90, 0, 0])
            cylinder_c(nut_thick+clearance+break_edge, nut_radius/cos(30)+tolerance, chamfer1=break_edge, chamfer2=-2*break_edge, faces=6);
            
            translate([0, max(2*chamfer, clearance)/2-chamfer, 0])
            rotate([-90, 0, 0])
            cylinder_c(tube+wall_thick+2*chamfer-max(2*chamfer, clearance)/2, bolt_radius+tolerance, chamfer=-2*chamfer);
        }
        
        //mounting holes to the slides
        translate([total_mount_clearance[1]-bearing_offset-bolt_head_plate, 0, z_plate_thick/2+chamfer]) {
        translate([0, slide_length+top_bearing_seperation-z_mount_thick+chamfer, 0])
        rotate([90, 0, 0])
        cylinder_c(2*wall_thick+2*chamfer, bolt_radius+tolerance, chamfer=-2*chamfer);
        
        translate([0, -2*wall_thick, 0])
        rotate([-90, 0, 0])
        cylinder_c(z_kingpin_offset[0]+tube+wall_thick, nut_radius/cos(30)+tolerance, chamfer=break_edge, faces=6);
        }
        //motor mount bolt holes
        if ( motor_mount == "motor" ) {
            for ( i = [ -1 : 2 : 1 ] )
            translate(z_kingpin_offset)
            rotate([0, 0, 45])
            translate([0, z_spacing/2, 0])
            {
                rotate([0, 0, -45])
                translate([i*motor_bolt_spacing/2, i*motor_bolt_spacing/2, 0])
                {
                    translate([0, 0, z_plate_thick+z_coupler_length-wall_thick])
                    cylinder_c(wall_thick+2*chamfer, motor_bolt_radius+tolerance, chamfer1=0, chamfer2=-2*chamfer);
                        
                    cylinder_c(z_plate_thick+z_coupler_length-wall_thick+2*chamfer+motor_bolt_radius+tolerance, (motor_width-motor_bolt_spacing)/2, chamfer1=-2*chamfer, chamfer2=(motor_width-motor_bolt_spacing)/2);
                }
                translate([0, 0, z_plate_thick+chamfer])
                    cylinder_c(z_coupler_length+chamfer, z_coupler_radius+clearance, chamfer1=chamfer, chamfer2=-2*chamfer);
            }
            
            //motor countersink
            translate(z_kingpin_offset)
            rotate([0, 0, 45])
            translate([0, z_spacing/2, z_plate_thick+z_coupler_length+chamfer])
            rotate([0, 0, -45])
            cube_c([motor_width+2*chamfer, motor_width+2*chamfer, 3*chamfer], bottom_chamfer=chamfer, top_chamfer=-chamfer);
        }
        
        difference() {
            union() {
            //cutout to save material 
            x_disp = z_kingpin_offset[0]-(tube+bolt_bezel-(nut_radius/cos(30)+tolerance+chamfer))*cos(45)-(wall_thick+tube)*cos(45);
            y_disp = z_kingpin_offset[1]+(tube+bolt_bezel-(nut_radius/cos(30)+tolerance+chamfer))*cos(45)-(wall_thick+tube)*cos(45);
            //bevel for the cutout
            for ( j = [ 0 : 1 ] )
            translate([0, 0, j*(z_plate_thick)-2*chamfer])
            hull() {
                for ( k = [ 0 : 1 ] )
                mirror([k,-k,0])
                translate([x_disp, y_disp, 0])
                translate([chamfer-(x_disp-2*bolt_head_plate+2*chamfer)/2, chamfer-(y_disp-bolt_head_plate+2*chamfer)/2+chamfer, chamfer])
                cube_c([x_disp-2*bolt_head_plate+2*chamfer, y_disp-bolt_head_plate+2*chamfer, 4*chamfer], chamfer=2*chamfer);
            }
            //cutout
            hull() {
                for ( k = [ 0 : 1 ] )
                mirror([k,-k,0])
                translate([x_disp, y_disp, 0])
                translate([-(x_disp-2*bolt_head_plate)/2, -(y_disp-bolt_head_plate)/2+chamfer, -chamfer])
                cube_c([x_disp-2*bolt_head_plate, y_disp-bolt_head_plate, 2*z_plate_thick], chamfer=chamfer);
            }
            }
            if ( motor_mount == "motor" )
            {
                translate([0, 0, chamfer])
                z_motor_mount();
            }
        }
    }    
}
module z_plate_blank(motor_mount)
{
    hull() 
    for ( i = [ 0 : 1 ] )
    mirror([i,-i,0]) {
        translate(z_kingpin_offset)
        rotate([0, 0, 360/16])
        cylinder_c(z_plate_thick, (tube+wall_thick)/cos(22.5), faces=8);
        
        translate([0, bolt_head_plate*tan(22.5), 0])
        cube_c([2*bolt_head_plate, 2*bolt_head_plate, z_plate_thick]);
    }
    
    for ( i = [ 0 : 1 ] )
    mirror([i,-i,0])
    hull() {
        translate([(bearing_offset+2*bolt_head_plate-total_mount_clearance[1]+z_kingpin_offset[1])/2-(bearing_offset+2*bolt_head_plate-total_mount_clearance[1]), top_bearing_seperation+slide_length-z_mount_thick-(2*wall_thick+nut_thick)/2, 0])
        cube_c([bearing_offset+2*bolt_head_plate-total_mount_clearance[1]+z_kingpin_offset[1], 2*wall_thick+nut_thick, z_plate_thick]);  
        
        translate([chamfer-bolt_head_plate, top_bearing_seperation+slide_length-z_mount_thick-(2*wall_thick+nut_thick)/2-(bearing_offset-total_mount_clearance[1]+bolt_head_plate), 0])
        cube_c([2*chamfer, 2*wall_thick+nut_thick, z_plate_thick]);  
    }
    {//plate to hold the motor standoffs
    if ( motor_mount == "motor" )
    z_motor_mount();
    }
}
module z_plate(motor_mount)
{   
    difference() {
        z_plate_blank(motor_mount);
        z_plate_cutouts(motor_mount);
    }
}
module z_carriage_cutouts()
{
    for ( i = [ 0 : 1 ] )
        mirror([0, 0, i])
        translate([0, 0, (z_carriage_height)/2-bolt_head_plate])
        for ( j = [ 0 : 1 ] )
        mirror([0, j, 0])
        translate([0, -z_spacing/2, 0])
        for ( k = [ 0 : 1 ] )
        mirror([k, 0, 0])
        rotate([0, 0, z_bearing_angle/2])
        rotate([0, 90, 0])
    {
        nut_cutout_depth = nut_thick+clearance;
        nut_trap_depth = min( ((bearing_offset-(nut_radius+tolerance))*cos(45)-(chamfer/2))/cos(45), wall_thick+bearing_thick/2+washer+nut_cutout_depth );   
        {//bearing bolts
        translate([0, bearing_offset, bearing_thick/2+washer-chamfer])
        cylinder_c(nut_trap_depth-(bearing_thick/2+washer+nut_cutout_depth)+break_edge+chamfer, bolt_radius+tolerance, chamfer2=-2*break_edge, chamfer1=-2*chamfer);
        
        translate([0, bearing_offset, nut_trap_depth-break_edge])
        cylinder_c(wall_thick+bearing_thick/2+washer+nut_cutout_depth-nut_trap_depth+break_edge, bolt_radius+tolerance, chamfer1=-2*break_edge, chamfer2=chamfer);
        
        }
        {//nut traps
        //nut trap
        translate([0, bearing_offset, (nut_trap_depth-nut_cutout_depth)]) 
        hull()
        for ( s = [ 0 : 1 ] )
        translate([-s*bolt_head_plate, 0, 0])
        cylinder_c(nut_cutout_depth, nut_radius/cos(30)+tolerance, chamfer=break_edge, faces=6);
        
        //bevel for the nut traps
        translate([-bolt_head_plate, bearing_offset, nut_trap_depth-nut_cutout_depth-break_edge]) 
        cube_c([4*break_edge, 2*(nut_radius+tolerance+break_edge), nut_cutout_depth+2*break_edge], chamfer=2*break_edge);
        }
    }
    
    {//cutouts for the driving nuts
    for ( i = [ 0 : 1 ] )
    mirror([0, 0, i])
    translate([0, 0, z_carriage_height/2+chamfer])
    mirror([0, 0, 1])
    rotate([0, 0, 360/12])
    cylinder_c(nut_thick+clearance+anti_backlash_spring_length+chamfer, z_nut_radius/cos(30)+tolerance, chamfer2=break_edge, chamfer1=-2*chamfer, faces=6);
    }
    
    {//leadscrew cutout
    translate([0, 0, -(z_carriage_height-2*(nut_thick+clearance)+2*break_edge)/2])
    cylinder_c(z_carriage_height-2*(nut_thick+clearance)+2*break_edge, z_leadscrew_radius+tolerance, chamfer=-2*break_edge);
    }
    
    {//side cutouts
    for ( i = [ 0 : 1 ] )
    mirror([0, i, 0]) {
        //rail clearance cutout
        translate([0, z_spacing/2, -(z_carriage_height+2*chamfer)/2])
        rotate([0, 0, 360/16])
        cylinder_c(z_carriage_height+2*chamfer, (tube+clearance)/cos(22.5), chamfer=-2*chamfer, faces=8);
        
        //saving material
        translate([-z_carriage_thickness, z_spacing-tube-clearance-big_bevel, 0])
        rotate([0, 90, 0])
        cube_c([z_carriage_height-4*bolt_head_plate, z_spacing, 2*z_carriage_thickness], chamfer=-2*bolt_head_plate*cos(z_bearing_angle/2));
    }
    }
    {//mounting holes
        //horizontal_mount_hole_spacing
        for ( i = [ 0 : 1 ] )
        mirror([0, 0, i])
        for ( j = [ 0 : 1 ] )
        mirror([0, j, 0])
        {
        translate([(z_carriage_thickness+chamfer), horizontal_mount_hole_spacing, vertical_mount_hole_spacing])
        rotate([0, -90, 0])
        cylinder_c(2*(z_carriage_thickness)+chamfer+break_edge-(nut_thick+clearance), bolt_radius+tolerance, chamfer1=-2*chamfer, chamfer2=-2*break_edge);
            
        translate([nut_thick+clearance-(z_carriage_thickness), horizontal_mount_hole_spacing, vertical_mount_hole_spacing])
        rotate([0, -90, 0])
        rotate([0, 0, 360/12])
        cylinder_c(nut_thick+clearance+chamfer, nut_radius/cos(30)+tolerance, chamfer1=break_edge, chamfer2=-2*chamfer, faces=6);
        }
    }
}
module z_carriage_blank()
{
    {//bearing holders
    hull()
    for ( i = [ 0 : 1 ] )
    mirror([0, i, 0])
    translate([0, -z_spacing/2, 0])
    for ( j = [ -1 : 2 : 1 ] )
    translate([0, 0, j*(z_carriage_height-2*bolt_head_plate)/2])
    for ( k = [ 0 : 1 ] )
    mirror([k, 0, 0])
    rotate([0, 0, z_bearing_angle/2])
    rotate([0, 90, 0])
    translate([0, bearing_offset, bearing_thick/2+washer])
    rotate([0, 0, 360/16])
    cylinder_c(wall_thick, bolt_head_plate/cos(22.5), faces=8);
    }
}
module z_carriage()
{
    rotate([0, 90, 0])
    difference() {
        z_carriage_blank();
        z_carriage_cutouts();
    }
}
}
{//corners
module corner_socket_blank(mirrored, corner_type)
{
    //tube sleeve
    difference() {
        translate([0, corner_socket_bottom-(corner_socket_top+corner_socket_bottom)/2, 0])
        cube_c([corner_socket_sides, corner_socket_top+corner_socket_bottom, corner_depth], chamfer=corner_bevel);
        
        {//corner bevel to save some material
        corner_break = 1.5*corner_bevel;
        break_angle = atan(corner_bevel/(corner_bevel*cos(45)));
        
        translate([0, 0, corner_depth/2])
        for ( i = [ 0 : 1 ] )
        mirror([i, 0, 0])
        for ( j = [ 0 : 1 ] )
        mirror([0, j, 0])
        for ( k = [ 0 : 1 ] )
        mirror([0, 0, k])
        translate([-(3*corner_bevel+bolt_head_plate*tan(22.5)), -(-corner_bevel), -corner_depth/2])
        translate([corner_socket_sides, (corner_socket_top+corner_socket_bottom)/2, -corner_socket_sides/2])
        cube_c([corner_socket_sides, corner_socket_sides, corner_socket_sides], chamfer=corner_socket_sides/2);
        
        *mirror([mirrored, 0, 0])
        for ( e = [ 0 : (mirrored == 0) && (corner_type != "mirrored") ? 1:0 ] )    
        for ( i = [ ( mirrored ==1 ? 1:0 ) : 1 ] )
        translate([0, 0, (corner_depth)/2])
        mirror([0, 0, i])
        mirror([max(0, e, i), 0, 0])    
        translate([(-corner_break+corner_socket_sides/2), -corner_socket_bottom+corner_break, (corner_depth-corner_break)/2])
        rotate([0, 0, -135])
        rotate([-break_angle, 0, 0])
        translate([-(2*corner_break/cos(45)), -(2*corner_break/cos(45)), 0])
        cube([2*(2*corner_break/cos(45)), 2*(2*corner_break/cos(45)), 2*(2*corner_break/cos(45))]);
        }
    }  
    {//clamp bolt sleeve
    *for ( i = [ -1 : 2 : 1 ] )
    translate([0, (tube+bolt_head_plate), corner_depth/2-bolt_head_plate+i*(corner_depth/2-corner_bevel-bolt_head_plate)])
    cube_c([corner_socket_sides, 2*bolt_head_plate, 2*bolt_head_plate], chamfer);
    }
    {//bridging bevel between tube sleeves
    translate([0, 0, 0])
    hull()
    for ( i = [ 0 : 1 ] )
    translate([0, axis_seperation-corner_socket_bottom+(i-1)*corner_bevel, corner_depth/2-(corner_socket_sides-2*corner_bevel)/2])
    cube_c([corner_socket_sides+i*2*corner_bevel, 2*corner_bevel, corner_socket_sides-2*corner_bevel], corner_bevel);
    }
}
module corner_socket_cutouts()
{
    //tube cutout
    cylinder_c(corner_depth, tube+tolerance, chamfer=-chamfer);
    
    //clearance cut to remove motor flange interference
    for ( i = [ -1 : 2 : 1 ] )
    translate([0, 0, i*(corner_depth-chamfer)])
    cylinder_c(corner_depth, tube+tolerance+chamfer);
    
    //slot cutout
    for ( i = [ 0 : 1 ] )
    translate([0, 0, i*corner_depth])
    mirror([0, 0, i])
    difference() {
        union() {
            translate([0, (corner_socket_bottom+chamfer)/2, 0])
            cube_c([max(clearance, 2*chamfer), corner_socket_bottom+chamfer, corner_depth/2-corner_socket_sides/2-corner_bevel-chamfer], chamfer, chamfer, -chamfer); 
            
            translate([0, corner_socket_bottom, (corner_depth/2-corner_socket_sides/2-corner_bevel-chamfer)/2])
            rotate([90, 0, 0])
            cube_c([max(clearance, 2*chamfer), corner_depth/2-corner_socket_sides/2-corner_bevel-chamfer, 2*chamfer], chamfer, chamfer, -chamfer);
        }
      
        if ( i == 1 )
            translate([-3*chamfer/2, 0, 0])
            rotate([0, 90, 0])
            cube_c([max(2*(corner_bevel), 2*chamfer), 2*corner_socket_bottom, 3*chamfer], chamfer=-chamfer);
    }
    
    //clamp hole cutouts and countersinks
    for ( i = [ -1 : 2 : 1 ] )
    for ( j = [ 0 : 1 ] )
    mirror([j, 0, 0])
    translate([0, tube+bolt_head_plate, corner_depth/2+i*(corner_depth/2-corner_bevel-bolt_head_plate)])
    rotate([0, 90, 0])
    {
        translate([0, 0, -max(clearance, 2*chamfer)/2])
        cylinder_c(max(clearance, 2*chamfer)+break_edge, bolt_radius+tolerance+2*break_edge, chamfer=2*break_edge);
        
        translate([0, 0, max(clearance, 2*chamfer)/2-break_edge])
        cylinder_c(( (j == 0) && (i == -1) ? min(drive_motor_offset-motor_width/2-2*chamfer, corner_socket_sides/2):(corner_socket_sides/2) ) - max(clearance, 2*chamfer)/2+2*break_edge - ( j == 0 ? nut_thick:bolt_head_thick ) - clearance, bolt_radius+tolerance, chamfer=-2*break_edge);
            
        translate([0, 0, ( (j == 0) && (i == -1) ? min(drive_motor_offset-motor_width/2-2*chamfer, corner_socket_sides/2):(corner_socket_sides/2) ) - ( j == 0 ? nut_thick:bolt_head_thick ) - clearance])
        cylinder_c( ( j == 0 ? nut_thick:bolt_head_thick )+clearance, ( j == 0 ? nut_radius/cos(30):bolt_head_radius ) + tolerance, chamfer1=break_edge, chamfer2=-break_edge, faces=j == 0 ? 6:0);
        
        translate([0, 0, ( (j == 0) && (i == -1) ? min(drive_motor_offset-motor_width/2-2*chamfer, corner_socket_sides/2):(corner_socket_sides/2) ) - break_edge])
        cylinder_c(corner_depth, (nut_radius+break_edge)/cos(30)+tolerance, chamfer=break_edge, faces=j == 0 ? 6:0);
    }
}
module corner_blank(mirrored, motor_mount)
{
    {//the tube clamps
    rotate([90, 0, 0])
    for ( i = [ 0 : 1 ] )
    rotate([0, i*90, 0])
    mirror([0, i, 0])
    translate([0, -axis_seperation/2, -corner_depth/2])
    corner_socket_blank( i == 1 ? 1:0, mirrored);
    }
    {//drive axle    
    translate([horizontal_drive_axle_offset, horizontal_drive_axle_offset, -vertical_drive_axle_offset])
    rotate([0, 0, 360/16])
    cylinder_c(2*vertical_drive_axle_offset, (pulley_radius+clearance+chamfer)/cos(22.5), faces=8);
    }
    {//motor flange 
    distance_to_base = corner_socket_sides/2*cos(45)+(corner_depth/2+horizontal_drive_axle_offset-corner_bevel)*cos(45);
    motor_bezel = distance_to_base-(drive_motor_offset-motor_bolt_spacing/2)*cos(45)-motor_bolt_spacing/2*cos(45);
    end_of_clamp = (corner_depth/2-horizontal_drive_axle_offset)*cos(45)+(drive_motor_offset-corner_socket_sides/2)*cos(45)+corner_bevel*cos(45)-sqrt(2*pow(motor_bolt_spacing/2, 2)); 
     
    if ( motor_mount != "none" )    
    translate([0, 0, vertical_drive_axle_offset-2*wall_thick])
    hull() {
        translate([horizontal_drive_axle_offset+motor_bolt_spacing/2, motor_bolt_spacing/2-drive_motor_offset, 0])
        for ( j = [ 0 : 1 ] )
        rotate([0, 0, j*180])
        translate([j*motor_bolt_spacing, 0])
        rotate([0, 0, 360/16])
        cylinder_c(2*wall_thick, j == 1 ? (motor_bezel/cos(22.5)):(end_of_clamp/cos(22.5)), faces=8);    
     
        translate([0, corner_bevel-corner_socket_sides/2, 0])
        rotate([0, 0, -90])
        cube_c([2*chamfer, corner_depth, 2*wall_thick]);
    }
    }
    {//anchoring flange (old)
    //bolt flanges to bolt it down
    *for ( i = [ mirrored == "mirrored" ? 0:1 : mirrored == "mirrored" ? 0:1 ] )
    mirror([0, 0, i])
    hull() 
    for ( j = [ 0 : 2 ] )
    translate([3*bolt_head_plate-corner_socket_sides/2+corner_bevel-chamfer-max(0, j-1)*foot_bolt_spacing_xy-i*(corner_depth-corner_socket_sides)/2, -corner_depth/2-bolt_head_plate+min(1, j)*foot_bolt_spacing_xy+i*(corner_depth-corner_socket_sides)/2, -axis_seperation/2-corner_socket_top])
    cube_c([2*bolt_head_plate, 2*bolt_head_plate, wall_thick]);
    }
    {//bevel to avoid support material for a part of the clamp
    *mirror([0, 0, 1])
    hull()
    for ( i = [ 0 : 2 ] )
    translate([corner_depth/2-(corner_depth/2-horizontal_drive_axle_offset)/2, corner_bevel-corner_socket_sides/2-max(0, i-1)*(axis_seperation/2+corner_socket_top-vertical_drive_axle_offset-corner_bevel+chamfer), min(1, i)*(axis_seperation/2+corner_socket_top-vertical_drive_axle_offset-corner_bevel+chamfer)-axis_seperation/2-corner_socket_top])
    cube_c([corner_depth/2-horizontal_drive_axle_offset, 2*corner_bevel, 2*corner_bevel], chamfer=corner_bevel);
    }
    
}
module corner_cutouts(mirrored, motor_mount)
{
    {//tube clamp cutouts
    rotate([90, 0, 0])
    for ( i = [ 0 : 1 ] )
    rotate([0, -i*90, 0])
    mirror([0, i, 0])
    mirror([i, 0, 0])
    translate([0, -axis_seperation/2, -corner_depth/2])
    corner_socket_cutouts();
    }
    {//string drive path clearance
    clearance_cut_height = max(2*chamfer, axis_seperation/2+corner_socket_top-vertical_drive_axle_offset);
    if ( motor_mount != "none" )    
    translate([horizontal_drive_axle_offset+(drive_motor_offset+motor_width/2)/tan(22.5)-(pulley_radius+chamfer+clearance), (horizontal_drive_axle_offset+drive_motor_offset)/2-drive_motor_offset, vertical_drive_axle_offset])
    rotate([0, 0, 360/16])
    cylinder_c(clearance_cut_height+chamfer, (drive_motor_offset+motor_width/2)/tan(22.5)/cos(22.5), chamfer1=chamfer, chamfer2=-2*chamfer, faces=8);
        //cube_c([corner_depth, horizontal_drive_axle_offset+drive_motor_offset, clearance_cut_height], bottom_chamfer=chamfer, top_chamfer=-chamfer);
    }
    {//axle cutouts
    //axle hole
    translate([horizontal_drive_axle_offset, horizontal_drive_axle_offset, -(vertical_drive_axle_offset+chamfer)])
    cylinder_c(2*(vertical_drive_axle_offset+chamfer), bolt_radius+tolerance, chamfer=-2*chamfer);
    //axle nut trap
    for ( i = [ 0 : 1 ] )
    mirror([0, 0, i])
    hull()
    for ( j = [ 0 : 1 ] )
    translate([horizontal_drive_axle_offset+j*corner_depth, horizontal_drive_axle_offset+j*corner_depth, vertical_drive_axle_offset-(nut_thick+clearance)-3*wall_thick])
    rotate([0, 0, 360/12-45])
    cylinder_c(nut_thick+clearance, nut_radius/cos(30)+tolerance, chamfer=break_edge, faces=6);
    
    //pulley clearance
    for ( i = [ 0 : 1 ] )
    mirror([0, 0, i])
    for ( j = [ 0 : (axis_seperation/2+corner_socket_top-vertical_drive_axle_offset) > chamfer ? 1:0 ] )
    hull()
    for ( k = [ 0 : 2 ] )
    translate([horizontal_drive_axle_offset+(k == 1 ? corner_depth:0), horizontal_drive_axle_offset+(k == 2 ? corner_depth:0), j == 0 ? vertical_drive_axle_offset:(axis_seperation/2+corner_socket_top-chamfer)])
    rotate([0, 0, 360/16])
    cylinder_c(2*(corner_socket_top+corner_socket_bottom), (pulley_radius+chamfer+clearance+j*chamfer)/cos(22.5), chamfer=chamfer, faces=8);
    }
    {//motor mount cutouts
    if ( motor_mount != "none" )
    translate([horizontal_drive_axle_offset, -drive_motor_offset, vertical_drive_axle_offset])
    {
        //mount holes
        translate([motor_bolt_spacing/2, motor_bolt_spacing/2, 0])
        for ( i = [ 0 : 1 ] )
        rotate([0, 0, 90+max(0, i-1)*90])
        translate([0, i > 0 ? motor_bolt_spacing:0, -wall_thick-break_edge])
        cylinder_c(wall_thick+2*break_edge, motor_bolt_radius+tolerance, chamfer=-2*break_edge);
        
        //trimming the flange
        translate([0, motor_bolt_spacing/2-motor_bolt_radius-wall_thick-motor_width, -2*wall_thick])
        cube_c([corner_depth, 2*motor_width, 2*wall_thick], chamfer=-chamfer);
        
        for ( i = [ 0 : 1 ] )
        translate([motor_bolt_spacing/2, motor_bolt_spacing/2, 0])
        rotate([0, 0, 45+i*45])
        translate([0, -motor_width-motor_bolt_radius-wall_thick, -2*wall_thick])
        cube_c([corner_depth, 2*motor_width, 2*wall_thick], chamfer=-chamfer);
        
        //motor counersink
        translate([corner_depth/2-(motor_width/2+chamfer), 0, -2*wall_thick])
        cube_c([corner_depth, motor_width+2*chamfer, wall_thick], top_chamfer=chamfer, bottom_chamfer=-chamfer);
    }
    }
    {//foot bolt down (old)  
    *for ( i = [ mirrored == "mirrored" ? 0:1 : mirrored == "mirrored" ? 0:1 ] )
    mirror([0, 0, i])
    for ( j = [ 0 : 1 ] )
    translate([3*bolt_head_plate-corner_socket_sides/2+corner_bevel-chamfer-j*foot_bolt_spacing_xy-i*(corner_depth-corner_socket_sides)/2, -corner_depth/2-bolt_head_plate+j*foot_bolt_spacing_xy+i*(corner_depth-corner_socket_sides)/2, -axis_seperation/2-corner_socket_top-chamfer])
    cylinder_c(wall_thick+2*chamfer, bolt_radius+tolerance, chamfer=-2*chamfer);
    
    *mirror([0, 0, 1])
    for ( j = [ 0 : 0 ] )
    translate([3*bolt_head_plate-corner_socket_sides/2+corner_bevel-chamfer-(corner_depth-corner_socket_sides)/2, -corner_depth/2-bolt_head_plate+(corner_depth-corner_socket_sides)/2, -tolerance-vertical_drive_axle_offset])
    cylinder_c(2*(wall_thick+tolerance), bolt_head_radius+tolerance, chamfer=-chamfer-tolerance);
    }
    {//anchor bolt hole
    mirror([0, 0, mirrored == "mirrored" ? 0:1])
    {
        translate([0, 0, -axis_seperation/2-corner_socket_top-chamfer])
        cylinder_c(wall_thick+chamfer+break_edge, bolt_radius+tolerance, chamfer1=-2*chamfer, chamfer2=-2*break_edge);
        
        translate([0, 0, -axis_seperation/2-(corner_socket_top-wall_thick)])   
        cylinder_c(corner_socket_top-wall_thick, nut_radius/cos(30)+tolerance, chamfer=break_edge, faces=6);
    }
    }
}
module corner(mirrored, motor_mount="none")
{  
    rotate([90, 0, 0])
    rotate([0, 0, 45])
    mirror([mirrored == "mirrored" ? 1:0, mirrored == "mirrored" ? -1:0, 0])
    difference() {
        corner_blank(mirrored, motor_mount);
        corner_cutouts(mirrored, motor_mount);
    }
}
}
{//drive pulleys/gears/couplings
module motor_pulley()
{
}
module coupler()
{
}
}
{//assembly
module center_assembly()
{
    color(center_color)
    translate([0, 0, -top_mount_width])
    rotate([0, 90, 0])
    for ( i = [ 0 : 1 ] )
    translate([-i*2*top_mount_width, 0, 0])
    mirror([i, 0, 0])
    rotate([-i*90, 0, 0])
    mirror([0, i, 0])
    translate([0, -bearing_offset, slide_length-bolt_head_plate]) {
    mirror([0, 0, 1])
        bearing_slide("center");
        
    }
    
    for ( i = [ 0 : 1 ] )
    mirror([0, 0, i])
    color(z_color)
    translate([0, 0, total_mount_clearance[0]+top_mount_width])
    z_plate();
    
    color(z_color)
    translate([0, 0, total_mount_clearance[0]+top_mount_width+z_coupler_length])
    z_motor_plate();
    
    color(center_color)
    translate(z_kingpin_offset)
    rotate([0, 0, 45])
    translate([0, z_spacing/2, 0])
    rotate([0, -90, 0])
    z_carriage();
    
    color(color_metal)
    for ( i = [ 0 : 1 ] )
    mirror([i, -i, 0])
    translate(z_kingpin_offset)
    translate([0, 0, -(total_mount_clearance[0]+top_mount_width+z_plate_thick)])
    difference() {
        cylinder_c(2*(total_mount_clearance[0]+top_mount_width+z_plate_thick)+z_coupler_length, tube);
        translate([0, 0, -chamfer])
        cylinder_c(2*(total_mount_clearance[0]+top_mount_width+z_plate_thick)+z_coupler_length+2*chamfer, tube-3*chamfer, chamfer=-2*chamfer);
    }
}
module corner_assembly(mirrored)
{
    color(corner_color)
    rotate([0, 0, 135])
    rotate([90, 0, 0])
    corner(mirrored);
}
module total_assembly()
{
    
    for ( i = [ -1 : 2 : 1 ] )
    for ( j = [ -1 : 2 : 1 ] )
    translate([i*(tube_length/2-corner_depth/2), j*(tube_length/2-corner_depth/2), 0])
    rotate([0, 0, max(0, j)*180])
    rotate([0, i != j ? 180:0, 0])
    corner_assembly(i != j ? "mirrored":"not");
    
    rotate([0, 0, -90])
    center_assembly();
    
    color(perimeter_color)
    for ( i = [ 0 : 1 ] )
    rotate([0, 0, i*90])
    for ( j = [ 0 : 1 ] )
    mirror([j, 0, 0])
    translate([tube_length/2-corner_depth/2, bearing_offset, 0])
    rotate([0, i*180, 0])
    translate([0, 0, -axis_seperation/2])
    rotate([90, 0, 0])
    bearing_slide("perimeter");
    
    //perimeter rails
    for ( i = [ 0 : 3 ] )
    rotate([0, 0, i*90])
    translate([0, tube_length/2-corner_depth/2, axis_seperation/2-i%2*axis_seperation])
    rotate([0, 90, 0])
    translate([0, 0, -tube_length/2])
    color(color_metal)
    difference() {
        cylinder_c(tube_length, tube);
        translate([0, 0, -chamfer])
        cylinder_c(tube_length+2*chamfer, tube-3*chamfer, chamfer=-2*chamfer);
    }
    
    //crossing rails
    for ( i = [ -1 : 2 : 1 ] )
    rotate([0, 0, 45+i*45])
    translate([0, bearing_offset, -i*axis_seperation/2])
    rotate([0, 90, 0])
    translate([0, 0, -tube_length/2])
    color(color_metal)
    difference() {
        cylinder_c(tube_length, tube);
        translate([0, 0, -chamfer])
        cylinder_c(tube_length+2*chamfer, tube-3*chamfer, chamfer=-2*chamfer);
    }
}
}

//z_carriage();                                     // x1
//z_plate("motor");                                 // x1
//z_plate();                                        // x1
//bearing_slide("center");                          // x2
//bearing_slide("perimeter");                       // x4
//corner(motor_mount = "lower");                    // x1  //"lower motor"
//corner("mirrored", motor_mount = "upper");        // x1  //"upper motor"
//corner("mirrored");                               // x1  //"upper bolt down"
//corner();                                         // x1  //"lower bolt down"


//center_assembly();
//corner_assembly();
//total_assembly();
/*
echo("bolt lengths");
echo(3*wall_thick+nut_thick+2*washer+bearing_thick, "mm bolt x8, corner axle");
echo(corner_socket_sides, "mm bolt x16, corner clamp bolt");
echo(2*(total_mount_clearance[0]+top_mount_width+z_plate_thick)+nut_thick, "mm bolt x1, kingpin bolt");
echo(wall_thick+nut_thick+z_mount_thick, "mm bolt x4, z plate mounting bolt");
echo(bearing_thick+2*washer+wall_thick+nut_thick, "mm x8, z carriage bearing bolts");
echo(2*(tube+wall_thick), "mm bolt x6, z rail clamping");
echo(2*top_mount_width+nut_thick, "mm bolt x10, top bearing bolt");
echo(slide_wing_thick+2*washer+bearing_thick+nut_thick, "mm bolt x24, wing bearing bolt");
echo(2*(tube+wall_thick), "mm bolt x8, perimeter rail clamping");
echo("total number of bolts", 8+4+16+1+4+2+8+4*(4+2+2)+4);
echo("nuts", 8+16+1+4+8+6+10+24+8);
echo("bearings", 44);
echo("washers", 88);
//slide bearing bolts 35, perimeter clamp bolts 8, corner clamp bolts 16, drive axles 8, z rail clamps 6, z plate mounts 4, z carriage bearing bolts 8.

echo("other bolts (and their corresponding nuts/washers) you'll need: z carriage router mount (x4, length depends on your mount thickness), corner bolt downs (x8, lengths depends on the thickness of whatever you bolt them down to), motor mounting bolts (x6, length depends on how much you want it to thread into the motor)", "minimum length for motor mount bolts (plus however much you want it to thread into the motor):", wall_thick);
