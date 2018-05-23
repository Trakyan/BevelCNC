M8_cap = [ 4, 13.25/2, 8, 1.25, 30, 0 ];
M8_hex = [ 4, 13/2, 5.675 ];
M5_cap = [ 2.5, 8.7/2, 5 ];
M5_hex = [ 2.5, 8/2, 3.875 ];
M3_cap = [ 1.5, 5.7/2, 3 ];
M3_hex = [ 1.5, 5.5/2, 2.2 ];
//radius, head radius, head thick, pitch, sides on the head (i.e. 6 for hex, use 0 for round)
M8_nut = [ 4, 14/2, 8/2, 1.25, 30 ];
M5_nut = [ 2.7, 8/2, 5/2, 1.25, 30 ];
M3_nut = [ 1.8, 5.5/2, 3/2, 1.25, 30 ];
//thick, radius, thread radius, pitch, angle

M8_washer = 1.6;
M5_washer = 1;
M3_washer = 0.5;

//radius to use for nut circle is r=(listed radius)/cos(30);
bearing_608 = [ 7, 22/2, 8/2 ];
bearing_605 = [ 5, 16/2, 5/2 ];
bearing_623 = [ 4, 10/2, 3/2 ];
//thickness, outer radius, inner radius;

M3 = [ M3_cap, M3_nut, M5_washer, bearing_623 ];
M5 = [ M5_cap, M5_nut, M5_washer, bearing_605 ];
M8 = [ M8_cap, M8_nut, M8_washer, bearing_608 ];

//face width, body length, bolt spacing, shaft length, shaft radius, shaft length, key depth, key length, mounting bolt radius

NEMA17 = [ 42, 28, 32, 20, 5/2, 25, 0.5, 15, 3/2 ];
NEMA14 = [ 35.5, 30, 26, 24, 5/2, 24, 0.5, 15, 3/2 ];