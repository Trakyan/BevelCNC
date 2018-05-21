function rad_deg (radians)
    =radians/(2*pi)*360;
function polar(r, theta)
    =r*[sin(theta), cos(theta)];
function rotate_v(v, theta)
    =[cos(-theta)*v[0]-sin(-theta)*v[1], sin(-theta)*v[0]+cos(-theta)*v[1]];
function dist(a, b)
    =sqrt(pow(a[0]-b[0], 2) + pow(a[1]-b[1], 2));
function secant(x)
    =1/cos(x);
function cosec(x)
    =1/sin(x);
function cotangent(x)
    =1/tan(x);


//where  or if a circle intersects the X and Y axis
function int_circle_line(xy_circle, r_circle, y_axis, x_axis)
    =int_circle_line_disc(xy_circle, r_circle, y_axis, x_axis) < 0 ? undef:( y_axis == undef ? [xy_circle[0]+sqrt(-pow(xy_circle[1],2)+pow(r_circle,2)), xy_circle[0]-sqrt(-pow(xy_circle[1],2)+pow(r_circle,2))] : [xy_circle[1]+sqrt(-pow(xy_circle[0],2)+pow(r_circle,2)), xy_circle[1]-sqrt(-pow(xy_circle[0],2)+pow(r_circle,2))] );

function int_circle_line_disc(xy_circle, r_circle, y_axis, x_axis)
    =y_axis == undef ? pow(2*xy_circle[0],2)-4*(pow(xy_circle[1],2)+pow(xy_circle[0],2)-pow(r_circle,2)):pow(2*xy_circle[1],2)-4*(pow(xy_circle[0],2)+pow(xy_circle[1],2)-pow(r_circle,2));
    
function int_circles(xy1, r1, xy2, r2) //returns the two intersection points of a set of circles with centers at xy1 and xy2 and radiuses r1 and r2 respectively
    =   [
    [ 
    (xy1[0]+xy2[0])/2 + (r1*r1-r2*r2)/(2*pow( dist( xy1, xy2 ), 2))*(xy2[0]-xy1[0]) + 
    ( sqrt(2 * (r1*r1 + r2*r2)/pow( dist( xy1, xy2 ), 2 ) - pow( (r1*r1-r2*r2), 2 )/pow( dist( xy1, xy2 ), 4 ) - 1)*(xy2[1]-xy1[1])/2 ) , 
    
    (xy1[1]+xy2[1])/2 + (r1*r1-r2*r2)/(2*pow( dist( xy1, xy2 ), 2))*(xy2[1]-xy1[1]) + 
    ( sqrt(2 * (r1*r1 + r2*r2)/pow( dist( xy1, xy2 ), 2 ) - pow( (r1*r1-r2*r2), 2 )/pow( dist( xy1, xy2 ), 4 ) - 1)*(xy1[0]-xy2[0])/2 )
    ],
    
    
    [ 
    (xy1[0]+xy2[0])/2 + (r1*r1-r2*r2)/(2*pow( dist( xy1, xy2 ), 2))*(xy2[0]-xy1[0]) - 
    ( sqrt(2 * (r1*r1 + r2*r2)/pow( dist( xy1, xy2 ), 2 ) - pow( (r1*r1-r2*r2), 2 )/pow( dist( xy1, xy2 ), 4 ) - 1)*(xy2[1]-xy1[1])/2 ) ,
    
    (xy1[1]+xy2[1])/2 + (r1*r1-r2*r2)/(2*pow( dist( xy1, xy2 ), 2))*(xy2[1]-xy1[1]) - 
    ( sqrt(2 * (r1*r1 + r2*r2)/pow( dist( xy1, xy2 ), 2 ) - pow( (r1*r1-r2*r2), 2 )/pow( dist( xy1, xy2 ), 4 ) - 1)*(xy1[0]-xy2[0])/2 )
    ] 
        ];
        
function gear_teeth(teeth, center1, mesh1, center2, mesh2, limit_axis, limit, intersect, clearance) 
// teeth is an initial (overestimate) guess
//mesh1 center1 is the pitch radius and center of one gear its meshing with
//mesh2 center2 is the center seperation of the gear with the second gear it's meshing with and the center of the second gear
//limit axis is "x" or "y", along which axis the limit applies
//limit is the maximum distance along the axis the gear is allowed to reach
//intersect is "+" or "-", chooses if you use the + or - set of coored from int_circles
//clearance is if you want there to be some clearance between the gear and the limit
        = ( int_circles(center1, mesh1+pitch_radius(teeth), center2, mesh2 )[intersect=="+" ? 0:1][limit_axis=="x" ? 0:1] + outer_radius(teeth) + clearance < limit ? teeth:(teeth==1 ? "guess again?":(gear_teeth(teeth-1, center1, mesh1, center2, mesh2, limit_axis, limit, intersect, clearance))) );
        
function circle_res_correction(radius, res=res, corners=8)
    =(2*pi*radius)/(ceil(2*pi*radius/res/corners)*corners);