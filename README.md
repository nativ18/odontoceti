<h1> Summary </h1>

This project demonstrates how to use the device sensors - Magnetometer, Accelerometer and Gyroscope in order
to create an indoor mapping that would, later on, will be used in an indoor navigation app.


The main project was broken - it was written in Swift 3 and used a framework that doesn't exist in the repository, or anywhere else by its name.  
This fork was built in order to deal with those problems.

<h2>Fixes I've made:</h2>
I replaced the use of Linear.framework with Accelerate and Surge pods to provide the linear algebra functionality that this project so depends on.
While doing that I needed to rewrite parts of the math and even reinvent the wheel because I couldn't find some of the math methods in these pods.
Apart from this, I also upgraded it to Swift 5(instead of Swift 3) and dealt with a broken project file.


<h2>Current State:</h2>
The app starts successfully, registers all the sensors and sends the data to its processing unit.
Unfortunately, I cannot understand the visual results.
part of the reasons are:

1. I don't have a review of the product(how should it look like for example)
2. I might have an error in the math conversion from the Linear.framework to the Accelerate and Surge pods 
3. The main project contains bugs.


<h2>The purpose of this fork:</h2>
If you are interested in such a riddle and thrilled about indoor navigation solutions with no GPS whatsoever then please, please
join me on that effort!


<h3>#References:</h3>

1. This blog post - https://medium.com/@gregorymfoster/how-any-app-could-track-the-indoor-location-of-everyone-magnetic-localization-acf3707716de
2. The project main repository - https://github.com/gregorymfoster/odontoceti
3. Two companies that already were managed to solve it and go with it to production: 

Oriient: https://www.oriient.me/ and Indoor Atlas: https://www.indooratlas.com/
