/**
* Name: surimi
* Based on the internal empty template. 
* Author: LENOVO
*/
model surimi

global {
    file shape_file_cells <- shape_file("../includes/coords_cell.shp");
    file shape_file_ports <- shape_file("../includes/coords_port.shp");
    file vessel_csv <- csv_file("../includes/combined_vessel.csv", ",", true);

    geometry shape <- envelope(shape_file_cells);

   

 init {
    create cell from: shape_file_cells with:[id:string(read("id"))];
    create port from: shape_file_ports with:[name:: string(read("port"))];
    write "ports created = " + length(port);

    create vessel from: vessel_csv with: [
      name:: string(read("MMSI")),
      vlength:: string(read("vlength")),
      origin_port:: string(read("port")),
      gear:: string(read("gear"))
    ]{
  if (vlength = "VL1218") { vl <- 1; }
  else if (vlength = "VL1824") { vl <- 2; }
  else if (vlength = "VL2440") { vl <- 3; }
  else { vl <- 1; }
  }
    
   
    ask vessel {
    port p <- one_of(port where (each.name = origin_port));
    location <- p.location + { rnd(-3000, 3000), rnd(-3000, 3000) };
    }
   
}
}


species cell {
	string id;
    aspect base {
        draw shape color: #blue border: #black width: 1;
    }
}

species port {
    string name;
    aspect base {
        draw circle(5000) color: #red border: #black;

        if (name = "CHIAVARI") {
            draw name at: location + {1000, 1000} color: #black;
        } else {
            draw name at: location + {5000, 5000} color: #black;
        }
    }
}

species vessel {
	string name;
	string vlength <- "";
	string origin_port <- "";
	int vl <- nil;
	string gear <- "";

	aspect base {
        draw triangle(5000 * vl) color: #green border: #black rotate: 180;
    }
}

experiment surimi type: gui {
    output {
        display surimi type: 2d {
            species cell aspect: base;
            species port aspect: base;
            species vessel aspect: base;
        }
    }
}