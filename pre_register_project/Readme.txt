Details:
The following files are “excerpts” from a special "job application" project with pre-registration and a waiting list. It also included VIP-users with the ability to invite people (on the waiting list as well as not pre-registered users)
At that time the main idea behind was a “complete secret” preregistration with a “secret” invitation function - so that neither a visitor nor a "vip" with rights to send invitations could draw any conclusions whether someone was on the waiting list or not... (Admins could see the waiting list, but a VIP user was a special role...) Therefore some devise and invitation methods were overridden. (see devise_beta) 
Also it included tracking of the inviting person to reward him later with a bonus system.
As this functionality was dropped, I can share those publicly. Some project files are still in use, so I cannot share the complete source of the app.

Implementation:
* Rights and roles were defined via CanCan and rolify.
* Administration was done with active_admin
* Views were designed with HAML, for some dynamic partials, see create.js.haml as easy example
* Mail was connected to Mandrill, also the mails were designed in HTML and text
* As data storage I used a combination of MongoDB and PostgreSQL, and needed special attention as it wasn’t supported by Active_admin in 2013 (it isn’t until today without separate gems I think...)
* Specs were written with BDD in mind, so I used Cucumber (Gherkin) and Capybara. See “features” folder for some examples. Also, documentation was generated using yard.
* The app was localized in German and English on the front-end
* For development and testing, I was using Zeus to reduce re-boot time

To see some examples of some rspecs for a subproject based on some of the shared code, please see rspec_examples folder.

To see some more code examples, see jobboard folder. To see the running app as demo, visit jobapply-chris.herokuapp.com
