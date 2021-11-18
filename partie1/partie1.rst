.. _phase1_calm:

------------------------------------------------------------------------
1. Publication et déploiement d'une application avancée sur une marketplace
------------------------------------------------------------------------

Dans cette 1ère partie, nous allons faire connaissance avec Calm en clonant une application présente dans la marketplace, la modifier et la republier comme une nouvelle. 

Cloner une application de la marketplace
++++++++++++++++++++++++++++++++++++++++

#. Connectez vous sur PRISM Central avec votre utilisateur **USER**
#. Cliquez sur **Services > Calm**
#. Sélectionnez l'icone Marketplace 
    .. image:: images/1.png
       :alt: icône panier

#. Cliquez sur le bouton **Get** de l'application **Exemple**
#. Cliquez sur **Clone**
#. Renseignez les informations suivantes pour le blueprint :
    - Nom : **<Initiales>_Fiesta**
    - Projet : **Bootcamp**

Vous voilà avec un blueprint issu de l'application de la marketplace, nous allons pouvoir le modifier pour en faire notre propre application.

Aperçu du de l'interface MultiVM-Blueprint
++++++++++++++++++++++++++++++++++++++++++

Vous êtes à présent sur l'interface d'édition d'un blueprint en mode Multi-VM. Cliquez sur l'icône **Fiesta**.

- A gauche, on trouve le panneau des services et des profils. Il est souvent plus pratique de l'avoir en mode étendu, en cliquant sur l'icône de gauche qui se trouve en haut à gauche.
    .. image:: images/2.png
       :alt: Panneau des services

    - Dans ce panneau on va retrouver les services qui sont utilisés dans l'application. Par exemple ici, MariaDB qui sera une base de donnée, et Fiesta, une application marchange Web
    - "Update Config" est une entrée particulière permettant de changer les caractéritiques (vCPU, vRAM, catégories, etc.) des VM utilisées par les services
    - "Application Profiles" correspond à différents types de déploiements qu'on pourrait vouloir faire : Prod, PréProd, On-Prem, Cloud-Azure, Hybride. Par défaut il n'y a qu'un profile par défaut, le développeur des blueprints peut en créer autant qu'il le souhaite.
- Au centre on trouve la zone d'édition, dans laquelle les services sont représentés par des icones dans des cadres
    .. image:: images/3.png
       :alt: Représentation graphique des services

    - Sous l'icône on retrouve le nom du service (le même que celui qu'on retrouvait dans le panneau de gauche)
    - Au dessus de chaque service, on a le nom du substrat (comprendre VM ou conteneur) qui va l'exécuter. L'icône à gauche du nom permet de savoir quel environnement va faire fonctionner ce substrat. Le X vert et bleu correspond à un cluster Nutanix.
- A droite nous avons un panneau représentant les détails de l'élément sélectionné dans l'éditeur du blueprint. Il s'agit donc ici des détails du service MariaDB qu'on a sélectionné. Le contenu sera donc différent en fonction du type d'objet sélectionné.
    .. image:: images/4.png 
       :alt: Panneau détails

Caractéristiques d'un service
+++++++++++++++++++++++++++++

Lorsqu'un service est sélectionné, le panneau de détail affiche 3 onglets :
    .. image:: images/5.png
       :alt: Onglets du service

- L'onglet "VM" permet d'accéder aux détails de la VM, c'est ici qu'on va configurer la totalité des paramètres de cette dernière : vCPU, vRAM, vDisks, vNIC, catégories, etc...
- L'onglet "Package" permet de configurer les opérations pour installer et désinstaller l'application sur la VM. Par exemple, on va définir ici l'installation des binaires MySQL pour un service MySQL.
- L'onglet "Service" permet de définir 3 élements 
    - La description du service
    - Le nombre d'occurences de la VM qu'il est possible de déployer pour ce service
    - Les variables propres à ce service

Cliquez sur l'onglet "Package"
    .. image:: images/6.png
       :alt: Onglet Package

Sous le nom de package, cliquez sur **Configure install**. Dans la zone d'édition, sous le nom du service, on retrouve une représentation du "Package Install". 
    .. image:: images/7.png
       :alt: Install Package graphique

On voit que l'installation du package consiste en la succession de 3 tâches :

- Update OS
- Install npm
- Setup Festia app

Ces tâches peuvent être de 4 types : 

- Un script à exécuter sur la VM ou directement depuis Calm
- Une requête HTTP (pour les API)
- Une instanciation de variable
- Une pause

Les 3 tâches présentes ici, pour le pachage install, sont des scripts. En cliquant sur l'une d'elle, on a, dans le panneau de détail, le contenu de ce script.

Cliquez sur "Update OS" pour l'afficher 
    .. image:: images/8.png
       :alt: Script details

Il est possible d'afficher en grand le script pour une modification plus aisée en cliquant sur l'icône de gauche, en haut à droite.
    .. image:: images/9.png
       :alt: Zoom on script

Modification du blueprint
+++++++++++++++++++++++++

Nous allons modifier le blueprint que nous venons de copier depuis la Marketplace pour en faire une application fonctionnelle. 

Utilisation d'une variable Calm
-------------------------------

Calm dispose de variables qui peuvent être gérées manuellement par le développeur du blueprint, ou par Calm lui même. Nous allons en utiliser une dans 

Aller dans create de l'application pour voir
Modification de la tâche "Start the Fiesta App" dans le package install de Fiesta, et modification de MARIADB_IP par @@{MariaDB.address}@@
Aller dans create de l'application pour voir la dépendance qui s'est créé

Utilisation d'un crédential
---------------------------

Créer un credential Mariadb root+password
Le rendre personnalisable avec le bonhomme bleu
Modifier package install de MariaDB, tâche "Setup FiestaDB in MariaDB", et changer le mot de passe par le user.secret








In software engineering, CI/CD or CICD generally refers to the combined practices of continuous integration and either continuous delivery or continuous deployment. CI/CD bridges the gaps between development and operation activities and teams by enforcing automation in building, testing and deployment of applications.

There are `multiple CI/CD platforms <https://www.katalon.com/resources-center/blog/ci-cd-tools/>`_, including popular solutions like Jenkins. In this exercise we will deploy a platform called **Drone** due to its simplicity of deployment and basic use.

In addition to the CI platform, we will also require a supported version control manager to host our Fiesta source code. GitHub and GitLab are common, cloud-hosted solutions you would expect to see in many Enterprise environments. For the sake of providing a streamlined, self-contained lab, you will deploy an instance of **Gitea**. **Gitea** is a lightweight, open-source solution for self-hosting Git, with an interface similar to GitHub.

But first - your most important tool is your development environment!

In creating the initial containerized version of Fiesta, we used a command line text editor (ex. **vi** or **nano**) to manipulate files. While these tools can certainly do the job, as we've seen, this method is not exactly easy, or efficient to modify files on a large scale.

In this exercise, we'll graduate to **Visual Studio Code**. **Visual Studio Code** is a free source-code editor made by Microsoft for Windows, Linux and macOS. Features include support for debugging, syntax highlighting, intelligent code completion, snippets, code refactoring, and embedded Git.

Visual Studio Code (VSC)
++++++++++++++++++++++++

#. Connect to your **USER**\ *##*\ **-WinTools** VM via an RDP client using the **NTNXLAB\\Administrator** credentials.

   .. note::

      Refer to :ref:`clusterdetails` for Active Directory username and password information.

#. From the desktop, open **Tools > Visual Studio Code**.

#. Click **View > Command Palette...**.

   .. figure:: images/1.png

#. Type **Remote SSH**, and select **Remote-SSH: Connect Current Window to Host...**.

   .. figure:: images/2.png

#. Click on **+ Add New SSH Host...** and type **ssh root@**\ *<User##-docker_VM-IP-ADDRESS>* and hit **Enter**.

   .. figure:: images/2b.png

#. Select the location **C:\\Users\\Administrator\ \\.ssh\\config** (typically first entry) to update the config file.

#. Select **Connect** on the pop-up in the bottom right corner to connect to the VM.

   .. note::

      If you miss this dialog box:

      - Click **View > Command Palette...**
      - Type **Remote-SSH** and select **Remote-SSH: Connect to Host**
      - Select the **User**\ *##*\ **-docker_VM** IP

#. A new Visual Studio Code window will open. In the **Command Palette** make the following selections:

   - **Select the platform of the remote host** - Linux
   - **Are you sure you want to continue?** - Continue
   - **Password** - nutanix/4u

#. Press **Enter** to connect to the remote host.

   .. note::

      You can disregard the messages in the lower right-hand corner by clicking **Don't Show Again**.

      .. figure:: images/3.png

#. Click the **Explorer** button from the left-hand toolbar and select **Open Folder**.

   .. figure:: images/4.png

#. Provide the ``/`` as the folder you want to open and click on **OK**.

   Ensure that **bin** is NOT highlighted otherwise the editor will attempt to autofill ``/bin/``. You can avoid this by clicking in the path field *before* clicking **OK**.

   .. figure:: images/4b.png

#. If prompted, provide the password again and press **Enter**.

   The initial connection may take up to 1 minute to display the root folder structure of the **User**\ *##*\ **-docker_VM** VM.

   .. note::

      You can disregard the warning regarding **Unable to watch for file changes in this large workspace folder.**

#. Once the folder structure appears, open **/root/github**. You should see the cloned **Fiesta** repository, your **dockerfile** and **runapp.sh**.

   .. figure:: images/5.png

   Having a rich text editor capable of integrating with the rest of our tools, and providing markup to the different source code file types will provide significant value in upcoming exercises and is a much simpler experience for most users compared to command line text editors.

Deploying Gitea
+++++++++++++++

In this exercise we will deploy **Gitea** and its required **MySQL** database as containers running on your Docker VM using a **YAML** file and the ``docker compose`` command.

#. In **Virtual Studio Code**, select **Terminal > New Terminal** from the toolbar.

   .. figure:: images/6.png

   This will open a new SSH session to your **User**\ *##*\ **-docker_VM** VM using a terminal built into the text editor - *convenient!*

   .. note::

      You can also use your preferred SSH client to connect to **User**\ *##*\ **-docker_VM**. Using the **Virtual Studio Code** terminal is not a hard requirement.

#. You can expand the terminal window by clicking the **Maximize Panel Size** icon as shown below.

   .. figure:: images/6b.png

#. In the terminal, run the following commands to create the directories required for the deployment:

   .. code-block:: bash

       mkdir -p ~/github
       mkdir -p /docker-location/gitea
       mkdir -p /docker-location/drone/server
       mkdir -p /docker-location/drone/agent
       mkdir -p /docker-location/mysql

#. Run ``cd ~/github``.

#. Run ``curl --silent https://github.com/nutanixworkshops/CICDBootcamp/raw/main/docker_files/docker-compose.yaml -O`` to download the **YAML** file describing the CI/CD infrastructure.

   You can easily view the **YAML** file in **Visual Code Studio** by selecting and refreshing your **/github/** directory and selecting the **docker-compose.yaml** file.

   .. figure:: images/8b.png

#. Run ``docker login`` and provide the credentials for your Docker Hub account created during :ref:`environment_start`.

   .. note::

      If you opened the file in the previous step, you can click the **Maximize** icon in your Terminal session again to restore it to full screen.

#. Run ``docker-compose create db gitea`` to build the **MySQL** and **Gitea** containers.

   When returns you should see that the two services have been created, similar to below.

   .. figure:: images/9.png

#. Run ``docker-compose start db gitea`` to start the **MySQL** and **Gitea** containers.

Configuring Gitea
+++++++++++++++++

In order to use Gitea for authentication within Drone, which will be configued in a later step, Gitea must be configured to use **HTTPS**. As this is a lab environment, we will configure Gitea to use a self-signed SSL certificate.

To do so we will use ``docker exec`` to execute commands *within* the Gitea container.

#. Run ``docker exec -it gitea /bin/bash`` to access the Gitea container shell.

#. From the container's **bash** prompt, run ``gitea cert --host <IP ADDRESS OF THE DOCKER VM>``.

   This will create two files **cert.pem** and **key.pem** in the root of the container.

   .. figure:: images/10.png

#. Copy the \*.pem files by running ``cp /*.pem /data/gitea``

#. Run ``chmod 744 /data/gitea/*.pem``

#. Close the container shell by pressing **CTRL+D**

#. Open a browser and point it to **http://<IP ADDRESS DOCKER VM>:3000**

   .. note::

      The WinToolsVM has Google Chrome pre-installed.

#. Make the following changes to the default **Initial Configuration**:

   - Under **Database Settings**

     - **Host** - *<IP ADDRESS OF YOUR DOCKER VM>*:3306
     - **Password** - gitea

   .. figure:: images/10-1.png

   - Under **General Settings**

      .. note::

         Ensure you are updating the **Base URL** from **HTTP** to **HTTPS**!

     - **SSH Server Port**: 2222
     - **Gitea Base URL**: **https**://*<IP ADDRESS OF YOUR DOCKER VM>*:3000

   .. figure:: images/11.png

#. Click **Install Gitea** at the bottom of the page.

   You should receive an error indicating **This site can’t provide a secure connection**, which we will fix using the self-signed SSL certificate previously created.

#. Return to your existing **Visual Studio Code** session.

#. From the **Explorer** side panel, open **/docker-location/gitea/conf/app.ini**.

#. Add the following lines under the **[server]** section as shown in the image below:

   .. code-block:: ini

       PROTOCOL = https
       CERT_FILE = cert.pem
       KEY_FILE = key.pem

   .. figure:: images/12.png

#. Save the file.

#. From your terminal session, restart the container by running ``docker-compose restart gitea``.

#. Reload the browser (\https://*<IP ADDRESS OF YOUR DOCKER VM>*:3000).

   .. figure:: images/12b.png

   You should now receive a typical certificate error, which is expected using a self-signed certificate. Proceed to the login page (ex. Click **Advanced > Proceed to...**).

#. Click **Need an account? Register now.** to create the initial user account.

   By default, the first user account created will have full administrative priveleges within the Gitea application.

#. Fill out the following:

   - **Username** - nutanix
   - **Email Address** - nutanix@nutanix.com
   - **Password** - nutanix/4u

#. Click **Register Account**.

   .. figure:: images/14b.png

   You now have a self-hosted Git repository running inside of your Docker development environment as a container. The final step is to deploy and configure Drone.

Deploying Drone
+++++++++++++++

You may have noticed that the **Drone** service is described in the same **docker-compose.yaml** file as **Gitea** and its **MySQL** database service, yet we did not deploy it in the previous exercise. This is because we first need to update the **Drone** service **docker-compose.yaml** with some additional information from the **Gitea** deployment in order for **Drone** to use **Gitea** as a source for OAuth authentication services.

#. In **Gitea** (\https://*<IP ADDRESS OF YOUR DOCKER VM>*:3000), click the icon in the upper right-hand corner and select **Settings** from the dropdown menu.

   .. figure:: images/15.png

#. Select **Applications**.

#. Under **Manage OAuth2 Applications > Create a new OAtuh2 Application**, fill out the following:

   - **Application Name** - drone
   - **Redirect URI** - http://*<DOCKER-VM-IP-ADDRESS>*:8080/login

   .. figure:: images/15b.png

#. Click the **Create Application** button.

#. On the following screen, copy the **Client ID** and the **Client Secret** to a text file (ex. **Notepad**), as you will need both values in the following steps.

   .. figure:: images/16b.png

#. Click **Save**.

#. Return to your existing **Visual Studio Code** session.

#. From the **Explorer** side panel, open **/root/github/docker-compose.yaml**.

#. Under **drone-server > environment**, update the following fields:

   - **DRONE_GITEA_SERVER** - \https://*<IP ADDRESS OF DOCKER VM>*:3000
   - **DRONE_GITEA_CLIENT_ID** - *Client ID from Gitea*
   - **DRONE_GITEA_CLIENT_SECRET** - *Client Secret from Gitea*
   - **DRONE_SERVER_HOST** - *<IP ADDRESS OF DOCKER VM>*:8080

   .. figure:: images/17b.png

#. Under **drone-docker-runner > environment**, update the following fields:

   - **DRONE_RPC_HOST** - *<IP ADDRESS OF DOCKER VM>*:8080

   .. figure:: images/18b.png

#. Save **docker-compose.yaml**.

#. Return to your Terminal session.

#. Run ``docker-compose create drone-server drone-docker-runner`` to build the **Drone** containers.

#. Run ``docker-compose start drone-server drone-docker-runner`` to start **Drone**.

#. Open ``http://<DOCKER-VM-IP-ADDRESS>:8080`` in a new browser tab.

   .. note::

      This will try to authenticate the **nutanix** user defined as **DRONE_USER_CREATE** in the **docker-compose.yaml** file.

#. When prompted, click **Authorize Application**.

   .. figure:: images/19.png

#. You should be presented with the **Drone** UI, which will not yet have any source code repositories listed.

   .. figure:: images/18.png

.. raw:: html

    <H1><font color="#B0D235"><center>Congratulations!</center></font></H1>

You have successfully provisioned all the infrastructure for your CI/CD pipeline, **but** there is still more to be done:

- **Visual Studio Code** is a big usability upgrade over **vi** :fa:`thumbs-up`
- We still need to automate our container building, testing, and deployment :fa:`thumbs-down`
- The image is only available as long as the Docker VM exists :fa:`thumbs-down`
- The start of the container takes a long time :fa:`thumbs-down`

The following labs will address our :fa:`thumbs-down` issues - Let's go for it! :fa:`thumbs-up`
