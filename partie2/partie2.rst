.. _phase2_calm:

----------------------------------------------------
2. Création et déploiement d'une machine de dev/test
----------------------------------------------------

Pour la conteneurisation d'une application, nous allons avoir besoin d'une machine avec Docker installé, ainsi que quelques outils pratiques pour interagir avec Karbon/Kubernetes.

En général, ce type de machine est atribuée à un développeur, et il faut donc en déployer plusieurs en fonction du nombre de développeurs. De plus, il arrive qu'une fausse manipulation cause un problème sur cette machine, et il est donc nécessaire d'en redéployer régulièrement.

C'est typiquement un use-case adequat pour une solution d'automatisation telle que Calm. Nous allons donc, from scratch, créer un blueprint de déploiement d'une Docker-VM (qui sera en fait un peu plus que ça).

Initialisation du blueprint
+++++++++++++++++++++++++++

Nous allons commencer par créer un nouveau blueprint. Nous pourrions utiliser l'éditeur de BP mono-VM, mais nous allons préférer le multi-VM, qui sera plus intéressant pour cette phase d'apprentissage.

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

Notre blueprint vierge est créé. Félicitations.

Création d'une variable globale
+++++++++++++++++++++++++++++++

Nous allons définir ici une variable qui sera ensuite utilisée dans tout le blueprint : Initiales

#. Cliquez sur ``Application Profile > Default``
#. Dans la partie droite de la fenêtre, à droite de variables, cliquez sur le ``+``
    .. image:: images/10.png
       :alt: Add Variables
       :width: 250px

#. Dans les champs qui apparaissent dessous, renseignez :
    - Name : **Initiales** (Attention à la casse)
    - Data Type : **String**
    - Value : **XYZ**
    - Cliquez sur le bonhomme pour qu'il devienne bleu, afin que cette variable soit modifiable au lancement.
  
    .. image:: images/11.png
       :alt: Initiales variable
       :width: 350px

#. Sauvegardez avec
    .. image:: images/9.png
       :alt: Save
       :width: 150px


Creation du crendential
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
    - Cliquez sur les bonhomme au dessus à droite de ``Username`` et ``Password`` pour permettre leur modification lors de l'exécution.

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

Nous en avons fini avec la créationd des credentials.

Création du service et de sa VM
+++++++++++++++++++++++++++++++

Nous allonns maintenant créer le service DockerVM, et définir la VM qui va le porter.

.. Note::
   Un service peut être porté par une ou plusieurs VM, ou bien un pod K8s (nous le verrons plus tard)


#. Cliquez sur le ``+`` à coté de ``Services``
    .. image:: images/8.png
       :alt: Add Service
       :width: 150px

#. Un icône est apparue dans la partie centrale de l'éditeur. Il nous reste à personnaliser ce service via la partie droite de l'écran :
    - On commaence par préciser le nom du service. 
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
             hostname: @@{initials}@@-docker-vm
             ssh_pwauth: true
             users:
               - name: @@{CentOS.username}@@
                 chpasswd: { expire: False }
                 lock-passwd: false
                 plain_text_passwd: @@{CentOS.secret}@@
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
          :width: 150px
 
      

Ajout des tâches
++++++++++++++++

Par la bibliothèque
===================

Manuellement
============

Test d'un script
================

Déploiement
+++++++++++

Test de notre VM
++++++++++++++++