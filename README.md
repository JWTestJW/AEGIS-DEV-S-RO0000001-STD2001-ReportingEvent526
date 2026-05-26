# Repository for reportingEvent
1) Create(Request to create) GitHub repository for a new R project as GitHub user(e.g. doe_roche / 123456_roche)
- AEGIS admin creates a requested repository by using factory repo and templatle repo via workflow.
- Repo shall have dev/qa/main branches and some protection rules(e.g. prohibit to push to main directly).

2) <span style="color: red;">[Fisrt time only]</span>Update "Global Options" to use GIT and create a SSH key for RStudio user(linux user)
- Create your SSH key from Terminal windows(linux shell)  

  **### command example ###**  
    cd  
    ssh-keygen -t ed25519 -C "your email address for GitHub account(e.g. jane.doe@asia.roche.com / jane.doe@chugai-pharm.co.jp)"  
- Acquire public key on your home  

  **### command example ###**  
    cat ~/.ssh/id_ed25519.pub  
- Copy strings in your public key.  
- Go to GitHub and open "SSH and GPG keys" menu at your private Settings.  
- Click "New SSH key" button and register as your SSH key.  
- Register GitHub username and email address into your git configuration as follows.  

  **### command example ###**  
    git config --global user.email "jane.doe@asia.roche.com/jane.doe@chugai-pharm.co.jp"  
    git config --global user.name "doe_roche/123456_roche"  
    git config --global core.hooksPath .githooks  
    git config --global pull.rebase false  
  
3) Create a new R project(reporting activity) in mode of version control and using git  
- [Important!] Input URL which is not for HTTPS but for SSH  

4) Pull your own branch(e.g. dev) from Remote Repo(GitHub)  

5) Deploy following R initial files by invoking init_r.sh  
- .Renviron     for definition where is global cache  
- .Rprofile     for definition of custom logger to enable logging high-level info  

  **### command example ###**  
    cd <your project home>  
    ./init_r.sh  

6) Enable renv on Environments of "Project Options"

7) Confirm renv project status

- renv::project()
- renv::paths$cache()         #Global Cache
- renv::paths$library()       #Project Library
- renv::status()
- renv::snapshot()            #Create renv.lock file

8) (Option)In R4.3.1 container: change permission of the renv for project library to allow collaboration with others  
- Go to the project home and change permission.  

  **### command example ###**  
    chmod -R g+rwx renv/library/R-4.3/x86_64-pc-linux-gnu/renv  

9) Create your own R scripits under the project folder

10) Install required R packages from in-house PPM repository

11) Don't take a snapshot of renv.lock before merging to main branch

12) Commit and push to your own branch.
