.. _phase1_calm:

---------------------------------------------------------------------------
1. Publication et déploiement d'une application avancée sur une marketplace
---------------------------------------------------------------------------

Dans cette 1ère partie, nous allons faire connaissance avec Calm en clonant une application présente dans la marketplace, la modifier et la republier comme une nouvelle. 

Cloner une application de la marketplace
++++++++++++++++++++++++++++++++++++++++

#. Connectez vous sur PRISM Central avec votre utilisateur **USER**
#. Cliquez sur **Services > Calm**
#. Sélectionnez l'icone Marketplace 
    .. image:: images/1.png
       :alt: icône panier
       :width: 40px

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
       :width: 250px

    - Dans ce panneau on va retrouver les ``services`` qui sont utilisés dans l'application. Par exemple ici, MariaDB qui sera une base de donnée, et Fiesta, une application marchange Web
    - ``Update Config`` est une entrée particulière permettant de changer les caractéritiques (vCPU, vRAM, catégories, etc.) des VM utilisées par les services
    - ``Application Profiles`` correspond à différents types de déploiements qu'on pourrait vouloir faire : Prod, PréProd, On-Prem, Cloud-Azure, Hybride. Par défaut il n'y a qu'un profile par défaut, le développeur des blueprints peut en créer autant qu'il le souhaite.
- Au centre on trouve la zone d'édition, dans laquelle les services sont représentés par des icones dans des cadres
    .. image:: images/3.png
       :alt: Représentation graphique des services
       :width: 400px

    - Sous l'icône on retrouve le nom du service (le même que celui qu'on retrouvait dans le panneau de gauche)
    - Au dessus de chaque service, on a le nom du substrat (comprendre VM ou conteneur) qui va l'exécuter. L'icône à gauche du nom permet de savoir quel environnement va faire fonctionner ce substrat. Le X vert et bleu correspond à un cluster Nutanix.
- A droite nous avons un panneau représentant les détails de l'élément sélectionné dans l'éditeur du blueprint. Il s'agit donc ici des détails du service MariaDB qu'on a sélectionné. Le contenu sera donc différent en fonction du type d'objet sélectionné.
    .. image:: images/4.png 
       :alt: Panneau détails
       :width: 250px

Caractéristiques d'un service
+++++++++++++++++++++++++++++

Lorsqu'un service est sélectionné, le panneau de détail affiche 3 onglets :
    .. image:: images/5.png
       :alt: Onglets du service
       :width: 250px

- L'onglet ``VM`` permet d'accéder aux détails de la VM, c'est ici qu'on va configurer la totalité des paramètres de cette dernière : vCPU, vRAM, vDisks, vNIC, catégories, etc...
- L'onglet ``Package`` permet de configurer les opérations pour installer et désinstaller l'application sur la VM. Par exemple, on va définir ici l'installation des binaires MySQL pour un service MySQL.
- L'onglet ``Service`` permet de définir 3 élements 
    - La description du service
    - Le nombre d'occurences de la VM qu'il est possible de déployer pour ce service
    - Les variables propres à ce service

Cliquez sur l'onglet ``Package``
    .. image:: images/6.png
       :alt: Onglet Package
       :width: 400px

Sous le nom de package, cliquez sur ``Configure install``. Dans la zone d'édition, sous le nom du service, on retrouve une représentation du ``Package Install``. 
    .. image:: images/7.png
       :alt: Install Package graphique
       :width: 250px

On voit que l'installation du package consiste en la succession de 3 blocs. Ces blocs sont des tâches ou des appels à des actions :

- Update OS
- Install npm
- Setup Festia app

Une tâche peut être de 4 types : 

- Un script à exécuter sur la VM ou directement depuis Calm
- Une requête HTTP (pour les API)
- Une instanciation de variable
- Une pause

Une appel à une action permet d'exécuter une action qui a été définie dans un des services, et qu'on souhaite appeler, un peu comme on le fait avec une fonction dans un langage de programmation. Ces actions peuvent être automatiquement créées par Calm (Start, Stop, Restart, Create, Delete et Soft Delete) ou créées par le développeur, à sa convenance.

Les 3 blocs présents ici, pour le package install, sont des tâches exécutant des scripts. En cliquant sur l'un d'eux, on a, dans le panneau de détail, le contenu de ce script.

Cliquez sur ``Update OS`` pour l'afficher 
    .. image:: images/8.png
       :alt: Script details
       :width: 250px

Il est possible d'afficher en grand le script pour une modification plus aisée en cliquant sur l'icône de gauche, en haut à droite.
    .. image:: images/9.png
       :alt: Zoom on script
       :width: 400px

Modification du blueprint
+++++++++++++++++++++++++

Nous allons modifier le blueprint que nous venons de copier depuis la Marketplace pour en faire une application fonctionnelle 

Utilisation d'une variable Calm
-------------------------------

Calm dispose de variables qui peuvent être gérées manuellement par le développeur du blueprint, ou par Calm lui même. 

L'objectif est de faire en sorte que la configuration du webserver Fiesta soit faite automatiquement lors du déploiement de l'application complète. Il faut par exemple, renseigner l'IP de la base de données MariaDB dans les fichiers de configuration. 
C'est ce que nous allons faire.

Avant de réaliser cette opération, allons afficher les opérations réalisées lors de la création de l'application. Cliquez sur la ligne ``Create`` du profil ``Default`` dans le panneau gauche
    .. image:: images/10.png
       :alt: Create
       :width: 250px 

Dans la zone d'édiction au centre, vous devez voir ceci : 
    .. image:: images/11.png
       :alt: Create representation
       :width: 600px 

On y voit le workflow que va suivre Calm pour déployer l'application. Actuellement, les 2 services sont déployés en parallèle, avec les opérations suivantes :

``Create Deployment`` >> ``Substrate Create`` > ``Package Install`` > ``[Service] Create`` > ``[Service] Start``

Retournons maintenant dans le package install du webserver Fiesta. Pour cela : 
- Cliquez sur le service ``Fiesta`` au centre de la page
- Dans le panneau détails de droite, cliquez sur ``Päckage``
- Enfin, cliquez sur ``Configure Install``

Vous devez avoir cette vue :
    .. image:: images/12.png
       :alt: Padckage Install
       :width: 400px

Nous allons maintenant modifier le script de la tâche ``Setup Fiesta App``
    - Cliquez sur cette tâche dans la zone centrale de Calm
    - A droite, étendez le script pour avoir une zone d'édition plus confortable
    - Dans le script, ligne 6, vous avez : ``sudo sed -i "s/REPLACE_DB_HOST_ADDRESS/MARIADB_IP/g" /code/Fiesta/config/config.js``
    - Nous allons remplacer ``MADIADB_IP`` par la variable correspondant à l'IP de la VM du service MariaBD. 2 varaibles correspondent à cette IP :
       - MariaDB.address pour l'adresse du service
       - MariaDB_VM.address pour l'adresse de la VM
    - Renseignez cette variable à la place de ``MARIADB_IP`` dans le script. Pour rappel, une variable Calm est encadrée de ``@@{`` et ``}@@``.
    - Sauvegardez le blueprint avec le bouton en haut à droite de la page
       .. image:: images/13.png
          :alt: Save
          :width: 100px

    .. warning::
       Les variables citées si dessus ne sont pas intialisées au même moment dans l'exécution du blueprint :
          - ``[Service].address`` est valorisée après le démarrage du service
          - ``[substrat].address`` est valoridée après la création du substrat, et avant l'installation du package

       Cela peut avoir un impact dans votre développement de blueprint.
    
    .. note::
       Calm gère l'autocomplétion des variables. Si vous appuyez sur ``Ctrl + [Espace]`` dans un script, Calm proposera les variables possible en fonction du début de la zone de texte.
          .. image:: images/14.png
             :alt: completion
             :width: 300px

Nous avons positionné la variable, retournons sur l'action ``Create`` dans le profil. Vous devriez avoir cette vue :
    .. image:: images/15.png
       :alt: create avec dépendance
       :width: 600px

Comme vous poouvez le voir, un lien orange a été ajouté suite à l'utilisation de la variable (flêche rouge). Calm a constaté que vous utilisiez une variable qui allait être instanciée après la création du substrat (ou après le démarrage du service en fonction de la variable utilisée), et logiquement, il a inséré automatiquement une dépendance entre cet instant où la variable sera instanciée, et la tâche où cette variable est utilisée. 


Ajout d'un crédential
---------------------------

Dans le package install du service MariaDB, le mot de passe root du moteur de base de donnée est mentionné en dur dans le script, ce qui n'est pas du tout une bonne pratique, et qui va aussi causer son affichage dans les logs de déploiement de l'application sous Calm. 

Nous allons changer celà en ajoutant un credential dans le blueprint, et en permettant à l'utilisateur déployant l'application de personnaliser son mot de passe.

#. Commençons par aller dans ``Credentials``, en haut de l'éditeur Calm
    .. image:: images/16.png
       :alt: Credentials
       :width: 120px

#. Normalement, un crendential CentOS est déjà présent.
#. Cliquez sur le + à coté de ``Credentials``
    .. image:: images/17.png
      :alt: Plus
      :width: 150px

#. Une nouvelle zone de credential va s'afficher, renseignez les infos comme suit :
    - ``Credential name`` : **AdminDB**
    - ``Username`` : **root**
    - ``Secret Type`` : **Password**
    - ``Password`` : Mettez le mot de passe de votre choix

#. Cliquez ensuite sur le petit bonhomme sur la ligne ``Password`` pour qu'il devienne bleu. Cela signifie qu'on va laisser l'utilisateur modifier le mot de passe pour mettre celui de son choix quand il déploiera l'application.

Vous devriez avoir ceci : 
    .. image:: images/18.png
       :alt: Plus
       :width: 250px

#. Sauvegardez avec le bouton ``Save`` en haut à droite
#. Sortez de la page ``Credentials`` en cliquand sur ``Back`` à droite du bouton ``Save``

Il nous reste à utiliser ce credential dans nos scipts de notre blueprint :

#. Cliquez sur le service ``MariaDB``
#. Dans le panneau de détail à droite, cliquez sur ``Package``
#. Puis sur ``Configure Install``
#. Dans la partie centrale, cliquez sur la tâche ``Set root Password``
#. Agrandissez la fenêtre du script pour travailler de manière plus agréable
#. Ligne 4, vous pouvez constater que le mot de passe 'Nutanix/4u' est en clair et en dur dans le script
#. Remplacez ce mot de passe par la variable correspondant au mot de passe du credential : ``@@{AdminDB.secret}@@`` (en conservant les quotes qui l'entoure)
#. Sauvegardez le blueprint
#. Notre modification est terminé...

Test du déploiement du blueprint
++++++++++++++++++++++++++++++++

Avant de mettre ce blueprint dans la MarketPlace, il est préférable de le tester. 

Exécutons ce blueprint.

#. Il faut pour cela cliquer sur le bouton suivant :
    .. image:: images/19.png
       :alt: Launch
       :width: 100px

#. La fromulaire de lancement va s'affichier (vérifiez que vous êtes bien en mode ``Consumer`` en haut à droite)

#. Renseignez les données suivantes :
    - ``Application name`` : **|Vos initiales]-Fiesta-Test**
    - ``Àpplication description`` : Ce que vous souhaitez
    - ``Environmant`` : Laissez **All Projct Accouts**
    - ``App Profile`` : Laissez **Default**
    - ``Initials`` : Vos initiales
    - ``AdminDB > Password`` : Le mot de passe de votre choix
  
    .. image:: images/20.png
       :alt: Launch
       :width: 350px

#. Validez avec le bouton ``Deploy`` en bas de page
#. Une popup va s'afficher le temps de l'initialisation du déploiement
    .. image:: images/21.png
       :alt: popup
       :width: 350px
#. Vous arrivez ensuite automatiquement sur la page de l'application qui est en cours de provisionnement
    .. image:: images/22.png
       :alt: Application
       :width: 600px
#. En cliquant sur l'onglet ``Manage``, puis sur l'oeil à coté de ``Create``, vous allez pouvoir suivre le déploiement de l'application étapes par étapes. Un rond bleur signifie que l'opération est en cours, un rond vert qu'elle est terminée avec succès, et rouge signifie qu'un problème est survenu à cette étape.
    .. image:: images/23.png
       :alt: Launch
       :width: 600px
#. Dans la zone de droite, vous avez la possibilité de cliquer sur chacune des étapes pour voir le détail des opérations, et les logs des scripts qui ont été exécutés par Calm.
    .. image:: images/24.png
       :alt: Launch
       :width: 350px
#. A la fin du déploiement, l'application est notée ``running`` et toutes les tâches sont vertes
    .. image:: images/25.png
       :alt: Launch
       :width: 600px
#. Cliquez sur l'onglet ``services``
#. Sélectionner le service ``Fiesta``
#. A droite s'affiche les détails de la VM portant le serveur Web Fiesta, dont son IP
#. Survolez l'IP et cliquez sur l'icone ``copier`` pour copier cette IP.
    .. image:: images/26.png
       :alt: IP
       :width: 350px
#. Dans un navigateur internet, collez cette IP suivie de ``:5001``. Le site de vente en ligne Fiesta devrait s'afficher
    .. image:: images/27.png
       :alt: Fiesta
       :width: 600px
#. Le blueprint est validé, on peut supprimer l'application en retournant sur Calm, dans l'onglet ``Manage``
#. Sélectionnez ``Delete`` et cliquez sur la flêche à droite (Play)
    .. image:: images/28.png
       :alt: Delete
       :width: 200px
#. L'application va se supprimer. Attendez que ``Running`` devienne ``deleted``
    .. image:: images/29.png
       :alt: Deleted
       :width: 100px













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
