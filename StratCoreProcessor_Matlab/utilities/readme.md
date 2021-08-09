These functions and scripts are examples of code that can be used to analyze the outputs of the `StratCoreProcessor`. 

The main file to open and peruse is `flatten_beds_public_script`, which gives an example of converting a `.mat` file from the digitizer into a csv of values that can be imported into `litholog`. The other files in this folder are functions used in that script. 

`Zlogplot` is a function that will plot a graphic log `.mat` file from the digitizer. Simply load the file into Matlab, and then call `Zlogplot(name)`, where `name` is the name of the log in the Matlab workspace. 
