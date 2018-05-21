{//chamfers
{//cylinders
module cylinder_c (height, radius, chamfer=chamfer, chamfer1=0, chamfer2=0, res=res, angle=chamfer_angle, angle1=45, angle2=45, deg=360, faces=0)
{
    resolution = res;
    slices = faces > 0 ? faces:(ceil(2*3.14*max(radius, radius-chamfer)/resolution));
    chamfer1h = tan(angle1)*chamfer1;
    chamfer2h = tan(angle2)*chamfer2;
    chamferh = tan(angle)*chamfer;
    points = [
        [ 0, 0 ],
        [ radius-(chamfer1 > radius ? chamfer1-radius:chamfer1==0 ? chamfer:chamfer1), 0],
        [ radius, abs(chamfer1==0 ? chamferh:chamfer1h)],
        [ radius, height-abs(chamfer2h==0 ? chamferh:chamfer2h)],
        [ radius-(chamfer2 > radius ? chamfer2-radius:chamfer2==0 ? chamfer:chamfer2), height],
        [ 0, height]
            ];
    rotate_extrude(angle=deg, $fn=slices)
    polygon(points);
}
module cylinder_c_internal (height, radius, chamfer=chamfer, chamfer1=0, chamfer2=0, res=res, angle=chamfer_angle, angle1=45, angle2=45, deg=360, faces=0, thick)
{
    resolution = faces > 0 ? 2*pi*radius/faces : res;
    slices = ceil(2*3.14*max(radius+chamfer+thick, radius+thick)/resolution);
    chamfer1h = tan(angle1)*chamfer1;
    chamfer2h = tan(angle2)*chamfer2;
    chamferh = tan(angle)*chamfer;
    points = [
        [ radius+max(0, chamfer, chamfer1, chamfer2)+thick, 0 ],
        [ radius+(chamfer == 0 ? chamfer1:chamfer), 0],
        [ radius, abs(chamfer1==0 ? chamferh:chamfer1h)],
        [ radius, height-abs(chamfer2h==0 ? chamferh:chamfer2h)],
        [ radius+(chamfer == 0 ? chamfer2:chamfer), height],
        [ radius+max(chamfer, chamfer1, chamfer2)+thick, height]
            ];
    rotate_extrude(angle=deg, $fn=slices)
    polygon(points);
}
//chamfer=0;
//cylinder_c_internal(20,10, chamfer1=2, chamfer2=5, res=1, deg=180, angle=45, thick=1);
}

{//cubes
module cube_internal_chamfer(dimensions, chamfer=chamfer)
{
    hull() {
        for ( i = [ 0 : 2 ] )
        linear_extrude(chamfer, scale=(i == 2 ? 1:0))
        square([dimensions[0]-((i == 0)||(i == 2) ? (2*chamfer):0), dimensions[1]-((i == 1)||(i == 2) ? (2*chamfer):0)], center=true);
    }
}
module cube_external_chamfer(dimensions, chamfer=chamfer, chamfer_extension=0, cutout_compensation=chamfer)
{
    square_sides = 2*sqrt((pow(chamfer, 2)/2));
    chamfer_size = 2*sqrt((pow(chamfer+chamfer_extension, 2)/2));
    
    translate([0, 0, -chamfer_extension])
    hull() {
    for ( i = [ 0 : 1 ] )
        for ( j = [ 0 : 1 ] )
            mirror([j, 0, 0])
            for ( k =  [ 0 : 1 ] )
                mirror([0, k, 0])
                translate([dimensions[0]/2-chamfer, dimensions[1]/2-chamfer, -i*cutout_compensation])
                rotate([0, 0, 45])
                linear_extrude(chamfer+chamfer_extension-i*(chamfer+chamfer_extension-cutout_compensation), scale=(square_sides/(square_sides+chamfer_size))+i*(square_sides/(square_sides+chamfer_size)))
                square([square_sides+chamfer_size, square_sides+chamfer_size], center=true);  
    }
}
//translate([15, 20+chamfer*2, -10])
//cube_external_chamfer([30,40,10]);
module cube_chamfered (dimensions, chamfer=chamfer)
{
    square_sides = 2*sqrt((pow(chamfer, 2)/2));
    hull()
    for ( i = [0 : 1] )
        translate([0, 0, i*dimensions[2]+chamfer-2*i*chamfer])
        mirror([0, 0, 1-i])
    for ( i = [0 : 1] )
        mirror([0, i, 0])
        for ( i = [0 : 1] )
            mirror([i, 0, 0])
            translate([(dimensions[0]/2-chamfer), (dimensions[1]/2-chamfer), 0])rotate([0, 0, 45])
            linear_extrude(chamfer, scale=0)square(square_sides, center=true);
}
//cube_c([20,40,20], 5);
module cube_c_cutout (dimensions, chamfer=chamfer, cutout_compensation=undef)
{
    cutout_correction = cutout_compensation == undef ? chamfer:cutout_compensation;
    square_sides = 2*sqrt((pow(chamfer, 2)/2));
    linear_extrude(dimensions[2])
    hull()
    for ( i = [0 : 1] )
        mirror([0, i, 0])
        for ( i = [0 : 1] )
            mirror([i, 0, 0])
            translate([(dimensions[0]/2-chamfer), (dimensions[1]/2-chamfer), 0])rotate([0, 0, 45])
            square(square_sides, center=true);
    
    
    for ( k = [0 : 1] )
        translate([0, 0, k*dimensions[2]])
        mirror([0, 0, k])
        hull()
    for ( j = [0 : 1] )
        mirror([0, j, 0])
        for ( i = [0 : 1] )
            mirror([i, 0, 0])
            for ( m = [0 : 1] )
                translate([(dimensions[0]/2-chamfer), (dimensions[1]/2-chamfer), -m*chamfer])
                rotate([0, 0, 45])
                linear_extrude(m == 1 ? cutout_correction:chamfer, scale=0.5*max(m*2, 1))
                square(2*square_sides, center=true);
}
//cube_c_cutout([20,40,20], 5);
//cube([20,40,20], center=true);
module cube_c(dimensions, chamfer=chamfer, top_chamfer, bottom_chamfer, cutout_compensation=chamfer)
{   
    
    upper_chamfer = top_chamfer == undef ? chamfer:top_chamfer;
    lower_chamfer = bottom_chamfer == undef ? chamfer:bottom_chamfer;
    
    cube_chamfered(dimensions, abs(chamfer));
    
    if ( upper_chamfer < 0 )
        translate([0, 0, dimensions[2]])
        mirror([0, 0, 1])
        cube_external_chamfer(dimensions, abs(upper_chamfer), max(abs(upper_chamfer)-abs(chamfer), 0), cutout_compensation);
    
    if ( lower_chamfer < 0 )
        cube_external_chamfer(dimensions, abs(lower_chamfer), max(abs(lower_chamfer)-abs(chamfer), 0), cutout_compensation);
}
//chamfer=3;
//cube_c([20, 20, 20], chamfer=-chamfer);
}
module pit_c(points, radius, chamfer=chamfer, resolution=0.01)
{
    slices = ceil(2*3.14*(radius+chamfer)/resolution);
    hull()
    for ( i = [0 : len(points)-1])
        translate(points[i])cylinder(abs(chamfer), radius, radius+chamfer, $fn=slices);
}
//pit_c([ [0,0,0], [20, 20,0], [20, 0, 0] ], 10, 1, 1);
module poly_cylinder_c(points, height, radius, chamfer=chamfer, chamfer1=0, chamfer2=0, res=res)
{
    chamfer_bottom = chamfer1 != 0 ? chamfer1:chamfer;
    chamfer_top = chamfer2 != 0 ? chamfer2:chamfer;
    resolution = res;
    slices = ceil(2*3.14*(radius+chamfer)/resolution);
    
    translate([0, 0, height-abs(chamfer_top)])pit_c(points, radius, chamfer_top, resolution);
    
    translate([0, 0, abs(chamfer_bottom)])mirror([0, 0, 1])pit_c(points, radius, chamfer_bottom, resolution);
    

    hull()
    for ( i = [0 : len(points)-1])
        translate(points[i])cylinder_c(height, radius, chamfer=min(abs(chamfer), radius), chamfer1=min(abs(chamfer_bottom), radius), chamfer2=min(abs(chamfer_top), radius), angle=45, faces=slices);
}

//poly_cylinder_c([ [0,0,0], [20, 20,0], [20, 0, 0] ], 10, 15, 5, chamfer1=2, chamfer2=-2, res=1);
}
module inside_chamfer(width, chamfer_size=chamfer, filleting_radius=filleting_radius, chamfer=chamfer)
{
    //a filleted chamfer for an inside corner.
    rotate([0, 90, 0])
    difference()    //corner chamfer
    {
    hull()  //corner chamfer blank
    {
        translate([chamfer, chamfer, -width/2])
        cylinder_c(width, chamfer, res=circle_res_correction(chamfer)); 
        
        translate([-(filleting_radius-chamfer)-chamfer_size, chamfer, -width/2])
        cylinder_c(width, chamfer, res=circle_res_correction(chamfer), deg=90); 
       
        translate([-(filleting_radius-chamfer)-chamfer_size, -(filleting_radius-chamfer)-chamfer_size, -width/2])
        cylinder_c(width, chamfer, res=circle_res_correction(chamfer), deg=90);  
        
        translate([chamfer, -(filleting_radius-chamfer)-chamfer_size, -width/2])
        cylinder_c(width, chamfer, res=circle_res_correction(chamfer), deg=90); 
    }    

    
        //corner chamfer cutouts
    translate([0, 0, -width/2-chamfer])
    poly_cylinder_c(
    [ 
    [-filleting_radius+chamfer, -filleting_radius+chamfer-chamfer_size, 0],
    [-filleting_radius+chamfer, -filleting_radius-chamfer-chamfer_size, 0],
    [-filleting_radius-chamfer-chamfer_size, -filleting_radius-chamfer-chamfer_size, 0],
    [-filleting_radius-chamfer-chamfer_size, -filleting_radius+chamfer, 0],
    [-filleting_radius+chamfer-chamfer_size*tan(chamfer_angle), -filleting_radius+chamfer, 0]
    ], 
    width+2*chamfer, filleting_radius-chamfer, 2*chamfer, res=circle_res_correction(filleting_radius+chamfer));
    }
}

module corner_chamfer_transition(chamfer=chamfer, filleting_radius=filleting_radius)
{
    
    difference()
    {
        translate([0, -(filleting_radius+chamfer), -(filleting_radius+chamfer)])
        cube([filleting_radius+chamfer, filleting_radius+chamfer, filleting_radius+chamfer]);
    
    hull()
        {
    translate([chamfer, -chamfer, -chamfer])
    mirror([1,0,0])
    pit_c(
    [ 
    [-filleting_radius+chamfer, -filleting_radius+chamfer-chamfer, 0],
    [-filleting_radius+chamfer, -filleting_radius-chamfer-chamfer, 0],
    [-filleting_radius-chamfer-chamfer, -filleting_radius-chamfer-chamfer, 0],
    [-filleting_radius-chamfer-chamfer, -filleting_radius+chamfer, 0],
    [-filleting_radius+chamfer-chamfer*tan(chamfer_angle), -filleting_radius+chamfer, 0]
    ], 
    filleting_radius-chamfer, chamfer, resolution=circle_res_correction(filleting_radius));
    
    translate([chamfer*tan(chamfer_angle), -chamfer, -chamfer])
    rotate([0, -90, 0])
    pit_c(
    [ 
    [-filleting_radius+chamfer, -filleting_radius+chamfer-chamfer, 0],
    [-filleting_radius+chamfer, -filleting_radius-chamfer-chamfer, 0],
    [-filleting_radius-chamfer-chamfer, -filleting_radius-chamfer-chamfer, 0],
    [-filleting_radius-chamfer-chamfer, -filleting_radius+chamfer, 0],
    [-filleting_radius+chamfer-chamfer*tan(chamfer_angle), -filleting_radius+chamfer, 0]
    ], 
    filleting_radius-chamfer, chamfer, resolution=circle_res_correction(filleting_radius));
    
    translate([(2*filleting_radius-chamfer+chamfer), -chamfer, -(2*filleting_radius-chamfer+2*chamfer)])
    cylinder_c(chamfer*2, chamfer, res=circle_res_correction(chamfer));
    
    translate([(2*filleting_radius-chamfer+chamfer), -(2*filleting_radius-chamfer), -(2*filleting_radius-chamfer+2*chamfer)])
    cylinder_c(chamfer*2, chamfer, res=circle_res_correction(chamfer));
    
    translate([chamfer, -(2*filleting_radius-chamfer), -(2*filleting_radius-chamfer+2*chamfer)])
    cylinder_c(chamfer*2, chamfer, res=circle_res_correction(chamfer));
        }
        
       
    }
}
