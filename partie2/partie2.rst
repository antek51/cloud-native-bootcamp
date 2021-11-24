.. _phase2_calm:

----------------------------------------------------
2. Création et déploiement d'une machine de dev/test
----------------------------------------------------

Pour la conteneurisation d'une application, nous allons avoir besoin d'une machine avec Docker installé, ainsi que quelques outils pratiques pour interagir avec Karbon/Kubernetes.

C'est typiquement un type de machine qu'on va redéployer régulièrement, pour les raisons suivantes :
- En général on a une machine mise à disposition par développeur, il faudra donc en déployer plusieurs, et lors de chaque mouvement de personnel devant développer.
- Il arrive qu'une fausse manipulation cause un problème sur ce serveur, et qu'il soit donc nécessaire d'en redéployer une "neuve".

C'est donc un use-case adequat pour une solution d'automatisation telle que Calm. Nous allons donc, from scratch, créer un blueprint de déploiement d'une Docker-VM (qui sera en fait un peu plus que ça).

Initialisation du blueprint
+++++++++++++++++++++++++++

Nous allons commencer par créer un nouveau blueprint. 

Nous pourrions utiliser l'éditeur de BP mono-VM, mais nous allons préférer le multi-VM, qui sera plus intéressant pour cette phase d'apprentissage.

Créons ce Blueprint :

#. Aller dans le menu Blueprint avec l'icone dédiée :
    .. image:: images/1.png
       :alt: icône BP
       :width: 40px

#. Cliquez sur le bouton
    .. image:: images/2.png
       :alt: Create BP
       :width: 150px

#. Choisissez ``Multi-VM/Pod Blueprint``

#. Dans la fenêtre qui s'affiche, renseignez les données suivantes : 
    - Name : **[Initiales]_DockerVM**
    - Description : Ce que vous voulez
    - Projet : **Bootcamp**

#. Validez avec ``Proceed``

Notre blueprint vierge est créé, c'est un bon début.

Création des variables d'application
++++++++++++++++++++++++++++++++++++

Nous allons définir ici deux variables qui seront ensuite utilisées dans le blueprint :
    - Initiales : pour différencier nos VMs lors de leurs déploiement
    - Registry : qui sera l'IP de la registry docker privée utilisée dans notre lab
       - Nous avons besoin de la déclarer comme Registry autorisée mais non sécurisée, d'où cette variable.

#. Cliquez sur ``Application Profile > Default``
#. Dans la partie droite de la fenêtre, à droite de variables, cliquez sur le ``+``
    .. image:: images/10.png
       :alt: Add Variables
       :width: 250px

#. Dans les champs qui apparaissent dessous, renseignez :
    - Name : **Initiales** (Attention à la casse)
    - Data Type : **String**
    - Value : **XYZ**
    - Dans les options supplémentaires :
        - Label : **Vos intiales** 
    - Cliquez sur le bonhomme pour qu'il devienne bleu, afin que cette variable soit modifiable au lancement.
       .. image:: images/11.png
          :alt: Initiales variable
          :width: 350px

#. Ajoutez une autre variable avec :
    - Name : **Registry** (Attention à la casse)
    - Data Type : **String**
    - Value : laissez vide
    - Dans les options supplémentaires :
        - Label : **Registry privée**
        - Description : **Entrez ici l'IP de la registry privée** 
        - Marquez cette variable comme "Mandatory" 
    - Cliquez sur le bonhomme pour qu'il devienne bleu, afin que cette variable soit modifiable au lancement.
#. Sauvegardez avec
    .. image:: images/9.png
       :alt: Save
       :width: 150px


Création du crédential
+++++++++++++++++++++++

Dans notre blueprint, nous allons utiliser un compte paramétrable pour nous connecter sur cette machine virtuelle. Nous allons pour cela créer un crédential :

#. Cliquez sur ce bouton en haut de la page :
    .. image:: images/3.png
       :alt: Credentials
       :width: 150px

#. Cliquez sur le **+** de ce bouton :
    .. image:: images/4.png
       :alt: Add credential
       :width: 150px

#. Renseignez maintenant les informations demandées comme suit (attention à la casse): 
    - Credential Name : **CENTOS**
    - Usename : Ce que vous voulez. En général on va utiliser **centos**
    - Secret Type : **Password** 
       - on pourrait utiliser un certificat ici (Recommandé en production), mais pour des raisons de temps, on se contentera du password.

    - Password : Ce que vous voulez
    - Cliquez sur les bonhommes au dessus à droite de ``Username`` et ``Password`` pour permettre leur modification lors de l'exécution.

      .. image:: images/7.png
         :alt: Credential rempli
         :width: 350px

#. Validez ce credential en cliquant sur
    .. image:: images/5.png
       :alt: Save
       :width: 150px

#. Puis  
    .. image:: images/6.png
       :alt: Back
       :width: 150px

Nous en avons fini avec la création des credentials.

Création du service et de sa VM
+++++++++++++++++++++++++++++++

Nous allonns maintenant créer le service DockerVM, et définir la VM qui va le porter.

.. note::
   Un service peut être porté par une ou plusieurs VM, ou bien un pod K8s (nous le verrons plus tard)


#. Cliquez sur le ``+`` à coté de ``Services``
    .. image:: images/8.png
       :alt: Add Service
       :width: 150px

#. Un icône est apparue dans la partie centrale de l'éditeur. Il nous reste à personnaliser ce service via le panneau des détails à droite de l'écran :
    - On commence par préciser le nom du service. 
      - ServiceName : **DockerVM**
  
    - Ensuite, dans l'onglet VM, on va renseigner les informations suivantes ...
       - Nom du substrat : **VM** 
          .. warning::
             Attention, ce nom ne correspond pas au nom de la VM sous PRISM, mais juste le nom qu'a ce substrat sous Calm. Il sera notamment utilisé par les variables. Utilisons ici **VM** tout simplement, car il n'y en aura qu'une, et on ne va utiliser qu'un seul profil (le nom de ce substrat est également lié au profil)
       - Account : Laisser **NTNX_LOCAL_AZ** (il s'agit du cluster Nutanix sur lequel on se touve)
       - Operating System : **Linux**
       - VM Name : **@@{Initiales}@@-docker_VM**
       - vCPU : **2**
       - Cores per vCPU : **1**
       - Memory : **2**
       - Guest Customisation : Cochez, et copiez/Collez ce code
          .. code-block::

             #cloud-config
             preserve_hostname: false
             hostname: @@{Initiales}@@-docker-vm
             ssh_pwauth: true
             users:
               - name: @@{CENTOS.username}@@
                 chpasswd: { expire: False }
                 lock-passwd: false
                 plain_text_passwd: @@{CENTOS.secret}@@
                 sudo: ['ALL=(ALL) NOPASSWD:ALL']
                 groups: sudoers
             runcmd:
               - setenforce 0
               - sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
               - systemctl disable firewalld
               - systemctl stop firewalld
  
       - Disk 1 :
          - Device Type : **Disk**
          - Device Bus : **SCSI**
          - Operation : **Clone from image service**
          - Image : **Centos7.qcow2**
          - Bootable : **Coché**

       - Disk 2 (cliquez sur le + à coté de Disk pour le créer)
          - Device Type : **Disk**
          - Device Bus : **SCSI**
          - Operation : **Allocate on Storage Container**
          - Size (GiB): **100**

       - NIC 1 (cliquez sur le ``+`` à coté de ``Network Adaptaters (NICS)`` pour l'afficher
          - **Primary**
          - Private IP : **Dynamic**

       - Check log-in upon create 
          - Cochez
          - Credential : **CENTOS**
          - Address : **NIC 1**
          - Connection Type : **SSH**
          - Connection Port : **22** 
          - Delay : **30**
          - Retries : **5**

    - Sauvegardez avec
       .. image:: images/9.png
          :alt: Save
          :width: 100px
 
On en a fini de la configuration de la VM qui fera tourner ce service. 

Pour résumer les tâches réalisées : on a défini les caractéristiques de la VM qui va être créée pour faire tourner Docker. On lui a défini un Cloud-Init qui permet de créer le user correspondant au credential **CENTOS**, et qui autorise un accès au sudo pour ce dernier.

Nous avons également mis en oeuvre 2 disques : 
    - Un pour l'OS copié depuis une image présente sur le cluster
    - Un vierge pour stocker les données Docker

Enfin, nous avons connecté notre VM au réseau pour pouvoir nous y connecter à distance via la carte **NIC1** et demandé à ce que la connexion soit testée et validée avec le user **CENTOS** lorsque la VM est créé.

Ajout des tâches pour le package install
++++++++++++++++++++++++++++++++++++++++

Maintenant que notre "coquille" est créé, il faut faire le nécessaire pour que les binaires souhaités soient déployés sur la VM. On va donc créer les tâches qui vont faire cette opération.

Voici un aperçu du résultat final :
    .. image:: images/12.png
       :alt: Package Install
       :width: 250px

Pour ajouter des tâches qui seront exécutées lors de la création de la VM, on va aller mettre à jour le "Package Install". Pour cela :

#. Cliquez sur le service à modifier dans le centre de la page (ici **DockerVM**)
#. Dans le panneau de droite, cliquez sur ``Package``
#. Dans le Package Name, mettez : **Installation Docker VM**
#. Cliquez sur ``Configure install``

Nous voilà prêts à configurer cette installation de package.


Par la bibliothèque
===================

Au centre de l'écran, vous devez avoir cette vue : 
    .. image:: images/13.png
       :alt: Package Install
       :width: 350px

Nous allons ajouter notre première tâche  :

#. Cliquez sur ``+ Task``
#. Dans le panneau de droite, le détail de la tâche s'est affiché
#. Donnez un nom à la tâche : **Update OS**
#. Dans le menu déroulant ``Type`` sélectionnez **Execute**
#. Dans Scipt Type : **Shell**
#. Pour le endpoint : Laissez vide
#. Calm dispose d'une bibliothèque de scripts mise à votre disposition, que vous pouvez enrichir à l'envie. Nous allons l'utiliser pour cette tâche :
    #. Cliquez sur :
          .. image:: images/14.png 
             :alt: Browse library
             :width: 150px
         
    #. Sélectionnez le script "Update CentOS"
    #. Cliquez sur le bouton blueu ``Select``
    #. Aucune variable n'est présente, on peut donc valider avec le bouton bleu ``Copy``
    #. Notre tâche a été renseignée dans notre blueprint, on peut continuer
#. Pour le credential : Utilisez **CENTOS**
#. On peut éventuellement sauvegarder notre blueprint

Manuellement
============

On peut également utiliser des scripts créés spécifiquement pour le blueprint, et c'est ce que nous allons faire pour les tâches suivantes qui sont particulières à notre besoin

#. Ajouter une tâche 
    - Nom : **Preparation for Docker**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : (Faites un copier/coller)
       .. code-block::

          #!/bin/bash

          # Install the needed tools
          sudo yum install -y util-linux git jq

          # Create the second disk and use it
          sudo fdisk /dev/sdb <<EOF
          o
          n
          p
          1


          w 
          EOF

          sleep 10
         
          # Create ext4 FS

          sudo mkfs.ext4 /dev/sdb1
          sleep 10

          # Create the Docker mountpoints and mount it to the second drive
          sudo mkdir -p /docker-location
          sudo mount /dev/sdb1 /docker-location

          # Add mount point to fstab
          drive_uuid=$(sudo blkid /dev/sdb1 | cut -d "\"" -f 2)
          sudo echo "UUID=$drive_uuid    /docker-location    ext4    defaults    1 3" | sudo tee -a /etc/fstab

#. Ajouter une tâche 
    - Nom : **Install Docker**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script :
       .. code-block::

          #!/bin/bash

          # Grab the installaition file
          curl -fsSL https://get.docker.com/ | sh

          # stopping docker
          sudo systemctl stop docker
          sleep 10

          # Change docker location to the new location
          sudo mkdir -p /docker-location/docker
          sudo mkdir -p /etc/docker
          sudo touch /etc/docker/daemon.json
          echo '{"data-root": "/docker-location/docker","storage-driver": "overlay2"}' | sudo tee -a /etc/docker/daemon.json
          sudo rsync -aP /var/lib/docker/ /docker-location/docker
          sudo rm -Rf /var/lib/docker/

          sleep 5
          # Start and enable the docker engine at boot time
          sudo systemctl start docker
          sudo systemctl status docker
          sudo systemctl enable docker
          docker info

          # Adding the centos user to the docker group
          sudo usermod -aG docker @@{CENTOS.username}@@

          # Install docker-compose
          sudo yum install -y docker-compose ; echo $?

          if [ $? -eq 1 ]
          then
             exit 0 
          fi

#. Ajouter une tâche 
    - Nom : **Reboot**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : 
       .. code-block::
          
          #!/bin/bash

          # Shutdown and reboot after 1 minute
          sudo shutdown -r --no-wall

#. Ajouter une tâche 
    - Nom : **Waiting foor reboot**
    - Type : **Delay**
    - Sleep Interval : **90**
    
#. Ajouter une tâche 
    - Nom : **Test Reboot**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : 
       .. code-block::

          #!/bin/bash

          echo "Boot ok

#. Ajouter une tâche 
    - Nom : **Authorize Private Registry**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : 
       .. code-block::

          #!/bin/bash

          #Add unsecure regidstry in docker configuration file

          cat /etc/docker/daemon.json | jq '. += { "insecure-registries" : ["@@{Registry}@@:5000"] }' > /tmp/daemon.txt

          echo "Verification :"
          cat /tmp/daemon.txt

          sudo mv /tmp/daemon.txt /etc/docker/daemon.json

          sudo systemctl restart docker

#. Sauvegarder le blueprint avec le bouton ``Save`` en haut de la page.

Actions arrêt/démarrage et relance
++++++++++++++++++++++++++++++++++

Afin de réaliser un blueprint propre et dans les règles de l'art, il faut définir les tâches qui seront exécutées lors du démarrage, de l'arrêt et de la relance de l'application.

Déployez le service ``DockerVM`` du panneau de gauche, 
    .. image:: images/15.png
       :alt: Package Install
       :width: 300px

Comme vous pouvez le voir, Calm a créé automatiquement des actions liées à ce service. Leur nom est assez équivoque pour que nous ne détaillions pas ici ce qu'elles signifient.

Start
=====

Nous allons modifier l'action ``Start`` pour démarrer Docker lorsqu'on fait un start de cette application :

#. Cliquez sur
    .. image:: images/16.png
       :alt: Start
       :width: 200px

#. L'affichage central affiche
    .. image:: images/17.png
       :alt: Start content
       :width: 300px

#. Cliquez sur ``+ Task`` et configurez la tâches ainsi :
    - Nom : **Start Docker**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : 
       .. code-block::

          #!/bin/bash

          sudo systemctl start docker

#. Sauvegardez le blueprint

Stop
====

On recommence avec l'action ``Stop``

#. Cliquez sur ``+ Task`` et configurez la tâches ainsi :
    - Nom : **Start Docker**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : 
       .. code-block::

          #!/bin/bash

          sudo systemctl stop docker

Restart
=======

On recommence avec l'action ``Restart``

#. Cliquez sur ``+ Task`` et configurez la tâches ainsi :
    - Nom : **Start Docker**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : 
       .. code-block::

          #!/bin/bash

          sudo systemctl restart docker


Ajout d'une action "Day 2"
++++++++++++++++++++++++++

Un blueprint est d'autant plus intéressant qu'on lui intègre des opérations de management récurentes. Par exemple, on peut imaginer ajouter une action de mise à jour de l'OS par exemple, mais il n'y a pas de limite à ce qu'on peut faire, si ce n'est votre imagination.

Créons cette action

#. Dans le panneau de gauche, allez dans le profil ``Default`` 
    .. image:: images/18.png
       :alt: Application actions
       :width: 300px

#. Cliquez sur le ``+`` à coté du mot ``Actions``
#. La partie centrale de la pages est mise à jour :
    .. image:: images/19.png
       :alt: New action
       :width: 300px

#. Dans la partie droite, donnez un nom à l'action : **Update OS**
#. Dans la partie centrale, cliquez sur ``+ Task`` (celui du haut) et configuez la tâche ainsi : 
    - Nom : **Update**
    - Type : **Execute**
    - Script Type : **Shell**
    - Endpoint : vide
    - Credentials : **CENTOS**
    - Script : Prenez le script ``Update CentOS`` de la bibliothèque, comme nous l'avons fait plus tôt dans ce lab.

#. Sauvegardez le blueprint

.. note::
   Vous aurez noté que notre action a été créé au niveau du profil (et donc de l'application) et non au niveau du service. Quand une application est déployée, on ne peut interagir qu'avec des actions positionnées au niveau de l'application et non pas au niveau du service.

   Pourquoi créer des actions au niveau du service alors ? Simplement car il est possible d'appeler ces actions propres au service depuis une action créée au niveau de l'application. C'est très pratique quand on veut utiliser plusieurs fois les mêmes tâches liées à un service, dans plusieurs actions d'application.

Test d'un script
++++++++++++++++

Déployer une application à partir d'un blueprint peut durer plus de 10mn si il y a beaucoup de substrats à créer, mais aussi pas mal d'actions à réaliser. Dans ce contexte, s'apercevoir que le blueprint a été mal codé et tombe en erreur peut s'avérer frustrant, surtout si, pour débugger, vous modifiez votre script érroné, et que vous relancez le blueprint complet, avec un résultat aléatoire.

Pour éviter cet écueil, Calm dispose d'un moyen de tester le script que vous êtes en train de faire, voyons comment.

#. Cliquez sur le service ``DockerVM``
#. Dans le panneau des détails à droite, cliquez sur ``Package``
#. Cliquez maintenant sur ``Configure Install``
#. Sur la partie centrale, sélectionnez la tâche ``Test reboot``
#. Il vous reste maintenent à cliquer sur ``Test script`` sous le script apparu à droite
    .. image:: images/20.png
       :alt: Test Script
       :width: 300px

#. Dans la fenêtre qui s'affiche, renseignez les infos suivantes :
    - IP Addess : **[Mettre ici l'IP de la registry privée]**
       - Cette adresse est logiquement une machine qui permet de faire des tests, ou la VM qui a été déployée dans la première exécution de votre blueprint, et qui est tombé en erreur. Ici nous utilisons cette VM hébergeant la registry pour des questions de simplicité du lab.
    - Port : **22**
    - Username : **centos**
    - Password : **nutanix/4u**

#. Cliquez maintenant sur ``login and test``
#. Vous arrivez alors sur cette fenêtre 
    .. image:: images/21.png
       :alt: Test Script
       :width: 600px

#. Vous pouvez lancer le test en cliquant sur
    .. image:: images/22.png
       :alt: Test 
       :width: 100px

#. Dans la partie inférieure de la page, la sortie standard de l'exécution s'affiche, et vous constatez une erreur, et un message signifiant qu'il manque un ``"``
#. Dans la partie haute, corrigez le script en fermant le ``echo`` en ajoutant ``"`` en fin de ligne
#. Retestez le script
#. Cette fois tout est ok 
    .. image:: images/23.png
       :alt: Test Script OK
       :width: 600px

#. On  peut donc sortir du testeur avec le bouton 
    .. image:: images/24.png
       :alt: Done 
       :width: 60px

#. Calm va alors vous demander si vous souhaitez conserver les modifications apportées au script
    .. image:: images/25.png
       :alt: Done 
       :width: 300px

#. Conservez ce script avec le bouton ``Save to blueprint``
#. Vérifiez/Constatez que le script de la tâche est bien la version corrigée
#. Sauvegardez votre blueprint corrigé.

Notre blueprint déployant une VM Docker et les outils K8S nécessaire pour la suite du lab est maintenant prêt et corrigé. Nous allons pouvoir déployer l'application.

Déploiement
+++++++++++

Pour déployer ce blueprint : 

#. Cliquez sur ``Launch`` en haut à droite de la page
#. Renseignez les infos suivantes :
    - Name : **[Initiales]-DockerVM**
    - Description : ce que vous voulez
    - Project : **Bootcamp**
    - Environment : **Default**
    - App Profile : **Default**
    - Private Registry : **[Mettre ici l'IP de la registry qu'on vous aura communiqué]**
    - Vos initiales : **[Vos initiales]**
    - Dans les credentials, vous pouvez modifier le user et le mot de passe utilisés pour se connecter si vous le souhaitez

#. Lancez l'exécution avec ``Deploy``
#. Attendez que l'application s'initialise
#. Cliquez sur ``Manage``
#. Cliquez sur ``Create``
#. Suivez le bon déroulement du déploiement, jusqu'à ce que l'application soit running.
    - Cela va prendre 10 bonnes minutes, le temps que l'OS soit mis à jour

.. note::
   Vous constaterez à gauche, dans les actions disponibles sur l'application, la présence de ``Update OS`` notre action de mise à jour de la VM.


Test de notre VM
++++++++++++++++

Une fois notre VM déployée, nous allons nous connecter sur la VM pour vérifier que docker est fonctionnel (normalement tout a déjà été testé dans les scripts).

#. Cliquez sur ``Services`` dans l'application
#. Cliquez sur ``DockerVM``
#. Le panneau de droite ce met à jour, et affiche les infos de la VM, dont son IP. 2 options pour notre test :
    - Faire un SSH depuis votre poste de rebond pour accéder à cette VM
    - Utiliser le terminal via le bouton ``Open terminal``
#. Cliquez sur ``Open terminal``
    - Notez que le credential par défaut va être utilisé pour réaliser la connexion sur la VM en SSH
#. Dans le terminal, exécutez la commande suivante : ``docker run --rm hello-world``
#. Si tout se passe bien vous devirez avoir la sortie suivante :
    .. image:: images/26.png
       :alt: Hello World
       :width: 350px

Félicitations, on a préparé notre VM Docker via Calm pour la suite des opérations. 
    .. image:: images/end.gif
       :alt: end
       :width: 400px