/**
* Name: surimi
* Based on the internal empty template. 
* Author: LENOVO
*/
model surimi

global {
    file shape_file_cells <- shape_file("../includes/coords_cell.shp");
    file shape_file_ports <- shape_file("../includes/coords_port.shp");
    geometry shape <- envelope(shape_file_cells);

   

 init {
    create cell from: shape_file_cells with:[id:string(read("id"))];
    create port from: shape_file_ports with:[name:string(read("port"))];
    
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

experiment surimi type: gui {
    output {
        display surimi type: 2d {
            species cell aspect: base;
            species port aspect: base;
        }
    }
}