/**
* Name: surimi
* Based on the internal empty template. 
* Author: LENOVO
*/
model surimi

global {
    file shape_file_grid <- shape_file("../includes/SMART_Data/grid_sf.shp");
    file shape_file_harbs <- shape_file("../includes/SMART_Data/harbs_df_sf.shp");
    file shape_file_aggr <- shape_file("../includes/SMART_Data/IBM.agg.grid_RP.shp");

    geometry shape <- envelope(shape_file_grid);
    map cell_by_idgrid <- map([]);
    map first_idgrid_of_cfr <- map([]);

 init {
    create cell from: shape_file_grid with:[
    	id_grid:string(read("id_grid")),
    	depth:int(read("depth"))
    ];
    
    ask cell {
    cell_by_idgrid[id_grid] <- self;
}
    
//    first_cell_of_cfr <- map([]);
    
    create harbour from: shape_file_harbs with:[
    	name::string(read("HARBOUR")), 
    	nvessel::int(read("NVESSEL"))
    ];
    
    
//    ask cell {
//    if (CFR != "" and !(first_cell_of_cfr contains_key CFR)) {
//        first_cell_of_cfr[CFR] <- self;
//    }
//}

//create vessel from: shape_file_aggr with: [
//    CFR:: string(read("CFR")),
//    id_grid:: string(read("id_grid"))
//];

create aggr_row from: shape_file_aggr with: [
    CFR:: string(read("CFR")),
    id_grid:: string(read("id_grid"))
];
first_idgrid_of_cfr <- map([]);

ask aggr_row {
    if (CFR != "" and !(first_idgrid_of_cfr contains_key CFR)) {
        first_idgrid_of_cfr[CFR] <- id_grid;
    }
}

loop cfr over: keys(first_idgrid_of_cfr) {

    create vessel {
        CFR <- string(cfr);
        id_grid <- string(first_idgrid_of_cfr[cfr]);

        if (cell_by_idgrid contains_key id_grid) {
            cell c <- cell_by_idgrid[id_grid];
            location <- c.location; // visible + consistent
            // optional jitter to avoid overlap:
            // location <- location + { rnd(-10,10), rnd(-10,10) };
        } else {
            location <- any_location_in(shape);
            write "No matching cell for vessel CFR=" + CFR + " id_grid=" + id_grid;
        }
    }
}

write "aggr rows=" + string(length(aggr_row)) + " | unique vessels=" + string(length(vessel));

//ask vessel {
//    if (cell_by_idgrid contains_key id_grid) {
//        cell c <- cell_by_idgrid[id_grid];
//        location <- c.location;   // guaranteed visible
//        // optional jitter to avoid overlap:
//        //location <- location + { rnd(-10, 10), rnd(-10, 10) };
//    } else {
//        location <- any_location_in(shape);
//        write "No matching cell for vessel CFR=" + CFR + " id_grid=" + id_grid;
//    }
//}
}
}    

species cell {
	string id_grid <- "";
	int depth <- 0;
    aspect base {
//        draw shape color: #blue border: #black width: 1;
	draw shape color: #blue border: #black width: 1;
    }
}

species harbour {
	string name <- "";
	int nvessel <- 0;
    aspect base {
//        draw shape color: #blue border: #black width: 1;
	draw circle(5000) color: #red border: #black;

    }
}

species vessel{
	string CFR <- "";
	string id_grid <- "";
	aspect base{
		draw triangle(5000) color: #green border: #black rotate: 180;
		
	}
}

species aggr_row {
    string CFR <- "";
    string id_grid <- "";
}

experiment surimi type: gui {

	output {
		display landscape type:2d {
			species cell aspect: base ;
			species harbour aspect: base;
			species vessel aspect: base;

		}
	}

}