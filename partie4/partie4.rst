.. _phase4_container:

------------------------
4. Utilisation du service CaaS Nutanix Karbon
------------------------

Dans ce module, nous allons utiliser le service **Nutanix Karbon**. 
Ce service est **natif** dans Prism Central et compatible avec l'hyperviseur Nutanix AHV. 
Karbon est la solution de gestion des clusters Kubernetes de production de Nutanix qui permet le provisionnement clé en main, les opérations et la gestion du cycle de vie de l'ensemble des couches d'infrastructure. Contrairement aux autres solutions Kubernetes, Karbon s'intègre de manière transparente à l'ensemble de la pile cloud native de Nutanix et simplifie considérablement Kubernetes sans verrouillage. Pour les clients Nutanix, Karbon est inclus dans toutes les éditions du logiciel AOS.

Le déploiement d'un cluster Kubernetes 
**lister les add-ons d'un cluster Karbon**


Activation du service Nutanix Karbon
+++++++++++++++++++++++++

Pour des raisons de temps, nous avons déjà activé et mis à jour Karbon. Vous pouvez néanmoins visionner comment s'active le service grâce à l'enregistrement suivant : 
   .. raw:: html 

      <iframe width="560" height="340"
      src="https://youtu.be/ahzB27LQSvQ">
      </iframe>      


   .. note::

      L'activation du service prend quelques minutes. En tâche de fond, l'outil déploie 2 conteneurs dans la VM Prism Central.      
        - **karbon-ui** prend en charge l'interface graphique, les requêtes API du moteur Karbon.
        - **karbon-core** est l'orchestrateur du runtime Kubernetes et tout ce qui est en r


Nous allons maintenant créer notre cluster Karbon et générer le fichier de déploiement de l'application pour l'héberger maintenant sur une base technologique de type cloud native. 

#. Dans le menu "burger" sélectionner **Services** puis **Karbon**. 

#. Vérifier que l'image **OS Images** est bien téléchargée. C'est l'image qui sera utiliser pour construire les machines virtuelles qui hébergeront le cluster Kubernetes. 

#. Créer maintenant votre cluster Kubernetes grâce au bouton **Create Kubernetes Cluster** 

   .. figure:: images/karbon1.jpg

#. Etape 1 : Selectionner un cluster de type **Development** pour des raisons simples de ressources disponibles sur la plateforme. 

   .. note::

      Un cluster de type **Development** consomme une minimum de 3 VMs : 1 Master, 1 etcd, 1 Worker.

      Un cluster de type **Production** consomme un minimum de 5 VMs : 2 Master, 3 etcs, 1 Worker. 


#. Etape 2 : Configuration générale
      - Donner un **nom** à votre cluster Kubernetes en respectant la nomenclature **user##-karbon**
      - Renseigner le cluster Nutanix qui hébergera le cluster Karbon (**ne pas modifier**)
      - Renseigner la version de Kubernetes souhaitée (**Selectionner la version la plus récente**)
      - Renseigner l'image Host OS à utiliser (**Selectionner la version la plus récente**)

   .. figure:: images/karbon2.jpg

#. Etape 3 : Configuration des noeuds 
      - Nous allons installer le cluster Karbon sur le réseau **Secondary** 
      - Nous laisserons les réglages par défaut des gabarits de VMs pour les différents rôles (Worker, Master, etcd)

   .. figure:: images/karbon3.jpg

#. Etape 4 : Configuration du réseau interne 
Cette étape permet de choisir le provider CNI de notre choix. Aujourd'hui Calico et Flannel sont intégrés nativement. D'autres CNI sont étudiés pour apporter d'avantage de choix pour les clients. 
      - Choisir entre **Flannel** ou **Calico** (cela n'a pas d'impact sur la suite sur lab)

   .. figure:: images/karbon4.jpg

#. Etape 5 : Configuration de l'accès au stockage 
      - Cette dernière partie va nous permettre de gérer la configuration de la couche de stockage "bloc" dont va pouvoir bénéficier le cluster Kubernetes pour les applications nécessitant du stockage persistent. (Laisser les réglages par défaut)

   .. figure:: images/karbon5.jpg

#. Pour finir cliquer sur **Create** pour lancer la création du cluster. Cela devrait prendre moins de 10 minutes. Vous pouvez monitorer l'avancement et observer l'apparition de nouvelles VMs sur le cluster Nutanix. 

Notre cluster Kubernetes est en cours de création et sera livré avec : 
      - le CNI de votre choix configuré
      - le driver CSI permettant l'accès au stockage bloc et fichier installé 
      - Une stack de gestion des logs EFK - ElasticSearch Fluentd Kibana permettant la gestion des logs du cluster k8s lui même 
      - Une gestion du monitoring et des métriques (node exporter, metric server, prometheus)


Connexion au cluster Kubernetes 
+++++++++++++++++++++++++
#. Vérifier que le cluster Karbon ai terminé son installation. 

#. Sélectionner votre cluster Karbon dans la liste et cliquer sur **Download kubeconfig**

#. Ouvrir le fichier **kubeconfig** et copier son contenu. 

#. Se connecter à notre docker VM en ssh. 

#. Créer un fichier dans le répertoire courant ``vi kubeconfig.cfg`` et coller le contenu du kubeconfig file téléchargé. 

#. Taper **ESC** pour terminer l'édition et sauvegarde avec **:wq**.

#. Modifier la variable d'environnement pour configurer la commande **kubectl**. 


Définition du manifest de l'application 
+++++++++++++++++++++++++

#. Pour interragir avec le cluster Kubernetes la cli native **kubectl** ainsi que d'autres outils. Ces outils ont été installés automatiquement sur votre machine docker. 
Retrouver donc votre machine docker et connecter vous en ssh. 

Notre cluster Kubernetes sera livré sans composant réseau tels que des load balancer, ingress controller, etc.

Pour mener à bien le lab, nous aurons à minima besoin d'un load balancer, nous allons donc installer et configurer Metallb grâce à Helm. 
Pour en savoir plus sur Helm visiter ce site : https://helm.sh/ 

Au préalable, nous aurons besoin de créer un fichier de configuration pour l'attribution des IPs externes à chacuns de vos load balancer Metallb. 

#. Créer un fichier dans le répertoire courant ``vi configmap-metallb.yaml``

#. Copier le contenu ci dessous en **prenant soin de modifier les plages d'adresses IP corresponsant à votre user** (cf la partie Environnement)

      .. code-block:: yaml
            apiVersion: v1
            kind: ConfigMap
            metadata:
            namespace: metallb-system
            name: metallb
            data:
            config: |
               address-pools:
               - name: default
                  protocol: layer2
                  addresses:
                  - XX.XX.XX.XX-XX.XX.XX.XX

#. Taper **ESC** pour terminer l'édition et sauvegarde avec **:wq**.



---
---
---
---



While the CI/CD pipeline is now capable of automating the build, test, upload to your Docker Hub registry, and deployment steps, you may have noticed it still takes multiple minutes for the **Fiesta_App** to be ready for use. In environments where you could see thousands of code pushes per day, *minutes matter!*

As you add additional containerized services to the pipeline, where operations are executed begin to have a significant impact on optimizing the build and deployment times of your application.

Currently, the container clones and builds the application source code *after* the container starts. We can shift these operations into the container image build process to decrease the time required for the running container to become ready.

In this exercise you will:

   - Update the **dockerfile** to include the Fiesta installation commands
   - Update **runapp.sh** to remove the Fiesta installation commands
   - Update **.drone.yml** to remove irrelevant image test commands
   - Test your updated build

Updating Fiesta_App Files
+++++++++++++++++++++++++

#. Return to your **Visual Studio Code (Local)** window and open **dockerfile**.

#. Overwrite **ALL** of the contents of the file with the following:

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

#. Save the file.

   .. note::

      We will **NOT** push the changes until all files have been updated.

   Now we see that the Fiesta application source code will be cloned and built on the Docker VM and *then* copied into the container on the ``COPY --from=base /code /code`` line.

   Not only will this decrease the start time of the application, it will also decrease the total size. This is because many additional *temporary* packages are downloaded by **npm** as part of the build process which are not automatically removed after the build has completed.

#. Open **runapp.sh** and overwrite **ALL** of the contents of the file with the following:

   .. code-block:: bash

      #!/bin/sh

      # If there is a "/" in the password or username we need to change it otherwise sed goes haywire
      if [ `echo $DB_PASSWD | grep "/" | wc -l` -gt 0 ]
          then
              DB_PASSWD1=$(echo "${DB_PASSWD//\//\\/}")
          else
              DB_PASSWD1=$DB_PASSWD
      fi

      if [ `echo $DB_USER | grep "/" | wc -l` -gt 0 ]
          then
              DB_USER1=$(echo "${DB_USER//\//\\/}")
          else
              DB_USER1=$DB_USER
      fi

      # Change the Fiesta configuration code so it works in the container
      sed -i "s/REPLACE_DB_NAME/$DB_NAME/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_HOST_ADDRESS/$DB_SERVER/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_DIALECT/$DB_TYPE/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_USER_NAME/$DB_USER1/g" /code/Fiesta/config/config.js
      sed -i "s/REPLACE_DB_PASSWORD/$DB_PASSWD1/g" /code/Fiesta/config/config.js

      # Run the NPM Application
      cd /code/Fiesta
      npm start

#. Save the file.

   The only thing the start-up script for our container is now responsible for is updating the **config.js** file with the environment variables and starting the application.

#. Open **.drone.yml**.

#. Under **steps > name: Test local built container > commands**, remove the line ``- git clone https://github.com/sharonpamela/Fiesta /code/Fiesta``.

   .. figure:: images/5.png

   This test is no longer needed as the source code as is now being cloned from GitHub outside of the container image.

#. Save the file.

Testing The Optimizations
+++++++++++++++++++++++++

#. Commit and push your 3 updated files to your **Gitea** repo.

#. In **Drone > nutanix/Fiesta_Application > ACTIVITY FEED**, note the the **build test image** stage now takes significantly longer as this is where we have shifted a majority of the operations.

   .. figure:: images/1.png

   This is a reasonable trade-off as for every build in an environment, you will likely have multiple deployments (development environments, user acceptance testing, production, etc.).

#. After the **Deploy newest image** stage is complete, return to your **Visual Studio Code (Docker VM SSH)** window and open the **Terminal**.

   .. note:: Alternatively, you can SSH to your Docker VM using PuTTY or Terminal.

#. Run ``docker image ls`` to list the images.

   .. figure:: images/3.png

   In the example above, the size of the image decreased by nearly 100MB. Again this is due to eliminating all of the additional temporary packages downloaded by **npm** when performing the application build inside of the container.

   Next we'll test how quickly the new image is able to start the Fiesta app.

#. Run ``docker stop Fiesta_App`` to stop and remove your container.

#. You can run ``docker ps --all`` to validate **Fiesta_App** container is no longer present.

   You should expect to see only your **drone**, **drone-runner-docker**, **gitea**, and **mysql** containers.

#. Copy and paste the script below into a temporary text file and update the **DB_SERVER** and **USERNAME** variables to match your environment and **Docker Hub** account.

   .. code-block:: bash

      DB_SERVER=<IP ADDRESS OF MARIADB VM>
      DB_NAME=FiestaDB
      DB_USER=fiesta
      DB_PASSWD=fiesta
      DB_TYPE=mysql
      USERNAME=<DOCKERHUB USERNAME>
      docker run --name Fiesta_App --rm -p 5000:3000 -d -e DB_SERVER=$DB_SERVER -e DB_USER=$DB_USER -e DB_TYPE=$DB_TYPE -e DB_PASSWD=$DB_PASSWD -e DB_NAME=$DB_NAME $USERNAME/fiesta_app:latest && docker logs --follow Fiesta_App

#. Paste the updated script into your SSH terminal session and press **Return** to execute the final command.

   The app should start in ~15 seconds, as indicated by ``You can now view client in the browser`` output from your terminal session. *That's significantly faster than the 3+ minutes it took previously!*

#. Optionally, if you want to compare the start time of your previous build:

   - Press **CTRL+C** to stop the ``docker log`` command
   - Run ``docker stop Fiesta_App``
   - Run ``docker image ls`` and note the **TAG** of one of your previous versions of the image, as indicated by its larger file size

      .. figure:: images/6.png

   - In the following command, replace **LATEST** with the **TAG** value from the previous step run ``docker run --name Fiesta_App --rm -p 5000:3000 -d -e DB_SERVER=$DB_SERVER -e DB_USER=$DB_USER -e DB_TYPE=$DB_TYPE -e DB_PASSWD=$DB_PASSWD -e DB_NAME=$DB_NAME $USERNAME/fiesta_app:LATEST && docker logs --follow Fiesta_App``

   - Run the command

   This version should take *much* longer than the optimized container image.

.. raw:: html

    <H1><font color="#B0D235"><center>Congratulations!</center></font></H1>

You've addressed the final issue in our CI/CD pipeline by optimizing the time it takes to deploy the application from the Docker container. :fa:`thumbs-up` What now?

Up to this point in the lab, every build has been dependent on the pre-deployed "production" version of our MariaDB database. In the next exercise, we'll take advantage of **Nutanix Era** to provide database cloning as part of the pipeline.
