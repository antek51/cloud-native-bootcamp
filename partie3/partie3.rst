.. _phase3_container:

------------------------------------------------
3. Conteneurisation de l'application
------------------------------------------------

Les conteneurs sont utilisés comme moyen pour délivrer des packages de logiciels qui incluent le code ainsi que toutes les dépendances dans une image. Cela permet à l'application d'être portable et ainsi d'être utilisé dans plusieurs environnements différents. 

Dans cette section, nous allons **convertir l'application "Fiesta" en conteneur** pour être ensuite hébergée dans un cluster Kubernetes en lieu et place d'un hébergement traditionnel en machine virtuelle. 


Construction du conteneur 
+++++++++++++++++++++++++++++++++

Dans cette section nous allons construire notre **conteneur avec l'application Fiesta et ses dépendances**.

Nous utiliserons :  

- Un **dockerfile** qui contiendra toutes les commandes à effectuer pour assembler une **image Docker**. 

- **Docker build** pour réaliser le travail de construction de l'image.

- Une **registry** permettant de mettre à disposition l'image dans une "bibliothèque" d'images privées


Nous allons maintenant utiliser la machine "Docker VM" que vous avez créé préalablement. 

#. Dans **PrismCentral**, naviguer dans le service **Calm** puis votre application déployée **[Initiales]_DockerVM**

#. Cliquer sur **Services** puis sur l'icône pour obtenir l'adresse IP 

#. Ouvrir une session SSH sur la machine avec le login / password que vous avez utilisés lors de la création du blueprint. 
   
#. Créer un répertoire ``mkdir github`` suivit de ``cd github``.

#. Executer un clone du repository ``git clone https://github.com/sharonpamela/Fiesta`` pour disposer d'une **copie locale du code de l'application**. 

#. Nous allons commencer à écrire notre **dockerfile**, créer le fichier ``vi dockerfile`` avec l'éditeur **vi**. 

   .. note:: Vous pouvez utiliser l'éditeur de texte de votre choix.

#. Taper **i** ou **insert** pour commencer à ajouter du texte dans le **dockerfile**. 

#. Copier et coller le contenu suivant : 


   .. code-block:: yaml

      # This dockerfile multi step is to start the container faster as the runapp.sh doesn't have to run all npm steps

      # Grab the Alpine Linux OS image and name the container base
      FROM ntnxgteworkshops/alpine:latest as base

      # Install needed packages
      RUN apk add --no-cache --update nodejs npm git

      # Create and set the working directory
      RUN mkdir /code
      WORKDIR /code

      # Get the Fiesta Application in the container
      RUN git clone https://github.com/sharonpamela/Fiesta.git /code/Fiesta

      # Get ready to install and build the application
      RUN cd /code/Fiesta && npm install
      RUN cd /code/Fiesta/client && npm install
      RUN cd /code/Fiesta/client && npm audit fix
      RUN cd /code/Fiesta/client && npm fund
      RUN cd /code/Fiesta/client && npm update
      RUN cd /code/Fiesta/client && npm run build

      # Grab the Alpine Linux OS image and name it Final_Image
      FROM ntnxgteworkshops/alpine:latest as Final_Image

      # Install some needed packages
      RUN apk add --no-cache --update nodejs npm mysql-client

      # Get the NMP nodemon and install it
      RUN npm install -g nodemon

      # Copy the earlier created application from the first step into the new container
      COPY --from=base /code /code

      # Copy the starting app
      COPY runapp.sh /code
      RUN chmod +x /code/runapp.sh
      WORKDIR /code

      # Start the application
      ENTRYPOINT [ "/code/runapp.sh"]
      EXPOSE 3001 3000


#. Taper **ESC** pour terminer l'édition et sauvegarde avec **:wq**.

#. Créer le fichier **runapp.sh** en tapant ``vi runapp.sh``.

#. Taper **i** ou **insert** pour commencer à ajouter du texte dans le fichier **runapp.sh**.

#. Copier et coller le contenu suivant : 


   .. code-block:: bash

      #!/bin/sh
      # Change the Fiesta configuration code so it works in the container
      sed -i "s/REPLACE_DB_NAME/FiestaDB/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_HOST_ADDRESS/$MARIADB_IP/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_DIALECT/mysql/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_USER_NAME/fiesta/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_PASSWORD/fiesta/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_DOMAIN_NAME/\/\/DB_DOMAIN_NAME/g" /code/Fiesta/config/config.js

      # Run the NPM Application
      cd /code/Fiesta
      npm start

   .. note:: 
      Le fichier runapp.sh sera executé au démarrage du conteneur. Il a pour objectif de modifier le fichier de configuration **config.js** de l'application Fiesta si il n'est pas à jour et de la démarrer ensuite.  
      
      A noter : **$MARIADB_IP** est l'adresse IP du service MARIADB et sera transmis en tant que variable d'environnement lors du lancement du conteneur. 


#. Taper **ESC** pour terminer l'édition et sauvegarde avec **:wq**.

#. Le dossier comprend un fichier **dockerfile** permettant de donner les insctructions sur la manière de construire l'image, le fichier **runapp.sh** qui sera copié dans l'image et le dossier **Fiesta** qui contient l'application. L'arborescence du dossier doit maintenant être équivalent à ceci : 

   .. figure:: images/docker2.jpg  


#. Il est temps de construire son image docker avec la commande suivante : ``docker build -t [INITIALES]-fiesta-app --no-cache .``

#. La commande ``docker image ls`` indique que l'image a bien été créée. 

Dans les organisations, l'utilisation d'une registry privée est conseillée pour des raisons de sécurité et de contrôle. 

#. Nous allons maintenant pousser l'application dans la registry pour permettre de l'utiliser depuis notre cluster Karbon avec les commandes : 

   - ``docker tag [INITIALES]-fiesta-app [IP-REGISTRY]:5000/[INITIALES]-fiesta-app``
   - ``docker push [IP-REGISTRY]:5000/[INITIALES]-fiesta-app``

#. Avant de passer à l'étape suivante, il est utile de tester le conteneur grâce à la commande ``docker run -d --rm -p 5001:3000 --env MARIADB_IP=[IP_MARIADB] --name=[INITIALES]-fiesta-app [IP-REGISTRY]:5000/[INITIALES]-fiesta-app:latest``

   .. note::
      La variable [IP_MARIADB] est à récupérer dans Calm. 


#. Vérifier le lancement du conteneur grâce à la commande ``docker ps`` et vérifier le nom de votre instance. 


#. Ouvrir un navigateur vers l'adresse ``http://[IP-DOCKER-VM]:5001``

   .. figure:: images/fiesta.jpg  


#. Stopper le conteneur grâce à la commande ``docker stop [INITIALES]-fiesta-app``




