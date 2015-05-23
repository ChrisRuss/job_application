Details:
The following files are “excerpts” from a job board I implemented for a headhunting agency. (For final result see a “small version” specially deployed to: http://jobapply-chris.herokuapp.com)
Implementation:
* Main framework was provided through RefineryCMS
* Most functionality was implemented as engines, see “vendor/extensions/jobposts” for more
* Implemented with Skinny controllers, fat models paradigm in mind
* Deployed to Heroku, S3 for file storage.
* Front-end design is based completely on Bootstrap framework and extended with SASS definitions
* PDF generation on the fly was done with wicked PDF and a special external Linux binary
* Of course I excluded admin files etc., as some of the code is still used in production ;-)

Examples for specs aren't included, see pre_register_project for some more coding examples with TDD Cucumber and for RSpec examples see rspec_examples.