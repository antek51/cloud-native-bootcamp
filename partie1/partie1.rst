.. _phase1_calm:

--------------------------------------------------------------------------
1. Publication et déploiement d'une application avancée sur la marketplace
--------------------------------------------------------------------------

Dans cette 1ère partie, nous allons faire connaissance avec Calm en clonant une application présente dans la marketplace, la modifier et la republier comme une nouvelle. 

Cloner une application de la marketplace
++++++++++++++++++++++++++++++++++++++++

#. Connectez vous sur PRISM Central avec l'utilisateur **admin** et le mot de passe **nx2Tech123!**
#. Cliquez sur les 3 traits en haut à gauche de la page, puis ``Services > Calm``
#. Sélectionnez l'icone Marketplace 

    .. image:: images/1.png
       :alt: icône panier
       :width: 40px

#. Cliquez sur le bouton **Get** de l'application **Exemple**
#. Cliquez sur **Clone**
#. Renseignez les informations suivantes pour le blueprint :
    - Nom : **<Initiales>_Fiesta**
    - Projet : **Bootcamp**
#. Clonez l'application avec le bouton ``Clone``

Vous voilà avec un blueprint issu de l'application de la marketplace, nous allons pouvoir le modifier pour en faire notre propre application.

Aperçu de l'interface MultiVM-Blueprint
+++++++++++++++++++++++++++++++++++++++

Vous êtes à présent sur l'interface d'édition d'un blueprint Multi-VM. Un blueprint est une "recette de cuisine" pour définir une application, de son déploiement, à sa suppression, en passant par toutes les actions que vous pourriez vouloir gérer pendant sa vie en production.

Cliquez sur l'icône **Fiesta**.

- A gauche, on trouve le panneau des services et des profils. 
    - Note : Il est souvent plus pratique de l'avoir en mode étendu, en cliquant sur l'icône de gauche qui se trouve en haut à droite du panneau.
       .. image:: images/2.png
          :alt: Panneau des services
          :width: 250px

    - Dans ce panneau on va retrouver les ``services`` qui sont utilisés dans l'application. Par exemple ici, MariaDB qui sera une base de donnée, et Fiesta, une application marchande Web
    - ``Update Config`` est une entrée particulière permettant de changer les caractéritiques (vCPU, vRAM, catégories, etc.) des VM utilisées par les services
    - ``Application Profile`` correspond à différents types de déploiements qu'on pourrait vouloir faire : Prod, PréProd, On-Prem, Cloud-Azure, Hybride. Par défaut il n'y a qu'un profil par défaut, le développeur des blueprints peut en créer autant qu'il le souhaite.
- Au centre on trouve la zone d'édition, dans laquelle les services sont représentés par des icones dans des "boîtes"
    .. image:: images/3.png
       :alt: Représentation graphique des services
       :width: 400px

    - Sous l'icône on retrouve le nom du service (le même que celui qu'on retrouvait dans le panneau de gauche)
    - Au dessus de chaque service, on a le nom du substrat (comprendre VM ou conteneur) qui va l'exécuter. L'icône à gauche du nom permet de savoir quel environnement va faire fonctionner ce substrat. Le X vert et bleu correspond à un cluster Nutanix.
- A droite nous avons un panneau représentant les détails de l'élément sélectionné dans l'éditeur du blueprint. Ci-dessous, on a les détails du service Fiesta. Le contenu est logiquement différent en fonction du type d'objet sélectionné.
    .. image:: images/4.png 
       :alt: Panneau détails
       :width: 250px

Caractéristiques d'un service
+++++++++++++++++++++++++++++

Lorsqu'un service est sélectionné, le panneau des détails affiche 3 onglets :
    .. image:: images/5.png
       :alt: Onglets du service
       :width: 250px

- L'onglet ``VM`` permet d'accéder aux détails de la VM, c'est ici qu'on va configurer la totalité des paramètres de cette dernière : vCPU, vRAM, vDisks, vNIC, catégories, etc...
- L'onglet ``Package`` permet de configurer les opérations ayant pour objectif d'installer et désinstaller l'application sur la VM. Par exemple, on va définir ici l'installation des binaires MySQL pour un service MySQL.
- L'onglet ``Service`` permet de définir 3 élements 
    - La description du service
    - Le nombre d'occurences de la VM qu'il est possible de déployer pour ce service
    - Les variables propres à ce service

Cliquez sur l'onglet ``Package``
    .. image:: images/6.png
       :alt: Onglet Package
       :width: 400px

Sous le nom de package, cliquez sur ``Configure install``. Dans la zone d'édition, sous le nom du service, on retrouve une représentation des opérations qui seront réalisées lors du ``Package Install``. 
    .. image:: images/7.png
       :alt: Install Package graphique
       :width: 250px

On voit que l'installation du package consiste en la succession de 3 blocs. Ces blocs sont des tâches ou des appels à des actions. On y trouve :

- Update OS
- Install npm
- Setup Festia app

Une tâche peut être de 4 types : 

- Un script à exécuter (sur la VM ou depuis Calm)
- Une requête HTTP (pour les API)
- Une instanciation de variable
- Une pause

Une appel à une action permet, lui, d'exécuter une action qui a été définie dans un des services, et qu'on souhaite appeler, un peu comme on le fait avec une fonction dans un langage de programmation. Ces actions peuvent être automatiquement créées par Calm (Start, Stop, Restart, Create, Delete et Soft Delete) ou créées par le développeur, à sa convenance.

Les 3 blocs présents ici, pour le package install, sont des tâches exécutant des scripts. En cliquant sur l'un d'eux, on a, dans le panneau des détails, le contenu de ce script.

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

.. note::
   On ne parle normalement pas de "variables" sous Calm, mais de "macros", il s'agit juste d'une terminologie différente pour un même concept. Nous avons gardé volontairement le terme "Variable" dans ce lab car il est plus commun et permet une meilleure compréhension.

L'objectif est de faire en sorte que la configuration du webserver Fiesta soit faite automatiquement lors du déploiement de l'application complète. Il faut par exemple, renseigner l'IP de la base de données MariaDB dans les fichiers de configuration. 
C'est ce que nous allons faire.

Avant de réaliser cette opération, allons afficher le workflow des opérations réalisées lors de la création de l'application.

Cliquez sur la ligne ``Create`` du profil ``Default`` dans le panneau gauche
    .. image:: images/10.png
       :alt: Create
       :width: 250px 

Dans la zone d'édition au centre, vous devez voir ceci : 
    .. image:: images/11.png
       :alt: Create representation
       :width: 600px 

On y voit le workflow que va suivre Calm pour déployer l'application. Actuellement, les 2 services sont déployés en parallèle, avec les opérations suivantes :

``Create Deployment`` > ``Substrate Create`` > ``Package Install`` > ``[Service] Create`` > ``[Service] Start``

Retournons maintenant dans le package install du webserver Fiesta. Pour cela : 

- Cliquez sur le service ``Fiesta`` au centre de la page
- Dans le panneau détails de droite, cliquez sur ``Package``
- Enfin, cliquez sur ``Configure Install``

Vous devez avoir cette vue :
    .. image:: images/12.png
       :alt: Padckage Install
       :width: 400px

Nous allons maintenant modifier le script de la tâche ``Setup Fiesta App``
    - Cliquez sur cette tâche dans la zone centrale de Calm
    - A droite, étendez le script pour avoir une zone d'édition plus confortable
    - Dans le script, ligne 6, vous avez : ``sudo sed -i "s/REPLACE_DB_HOST_ADDRESS/MARIADB_IP/g" /code/Fiesta/config/config.js``
    - Nous allons remplacer ``MADIADB_IP`` par la variable correspondant à l'IP de la VM du service MariaBD. 2 variables correspondent à cette IP :
       - MariaDB.address pour l'adresse du service
       - MariaDB_VM.address pour l'adresse de la VM
    - Renseignez une de ces variables à la place de ``MARIADB_IP`` dans le script. Pour information, une variable Calm est encadrée de ``@@{`` et ``}@@`` pour qu'elle puisse être interprétée.
    - Fermez la zone de script en cliquant sur le ``X`` en haut à droite.
    - Sauvegardez le blueprint avec le bouton en haut à droite de la page
       .. image:: images/13.png
          :alt: Save
          :width: 100px

    .. warning::
       Les variables citées si dessus ne sont pas intialisées au même moment lors de l'exécution du blueprint :
          - ``[Service].address`` est valorisée après le démarrage du service
          - ``[Substrat].address`` est valorisée après la création du substrat, et avant l'installation du package

       Cela peut avoir un impact dans votre développement de blueprint.
    
    .. note::
       Calm gère l'autocomplétion des variables. Si vous appuyez sur ``Ctrl + [Espace]`` dans un script, Calm proposera les variables possible en fonction du début de la zone de texte.
          .. image:: images/14.png
             :alt: completion
             :width: 300px

Nous avons positionné la variable, si vous retournez sur l'action ``Create`` dans le profil. Vous devriez maintenant avoir cette vue :
    .. image:: images/15.png
       :alt: create avec dépendance
       :width: 600px

Comme vous poouvez le voir, un lien orange (flêche rouge) a été ajouté suite à l'utilisation de la variable . Calm a constaté que vous utilisiez une variable qui allait être instanciée après la création du substrat (ou après le démarrage du service en fonction de la variable utilisée), et a logiquement automatiquement inséré une dépendance entre l'instant où la variable sera instanciée, et la tâche où cette variable est utilisée. 


Ajout d'un crédential
---------------------

Dans le package install du service MariaDB, le mot de passe root du moteur de base de données est mentionné en dur dans le script, ce qui : 

- n'est pas du tout une bonne pratique, et 
- va causer son affichage dans les logs de déploiement de l'application sous Calm. 

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
#. Fermez la page d'édition du script
#. Sauvegardez le blueprint

Notre modification est terminé

Test du déploiement du blueprint
++++++++++++++++++++++++++++++++

Avant de mettre ce blueprint dans la MarketPlace, il est préférable de le tester. 

Exécutons ce blueprint.

#. Il faut pour cela cliquer sur le bouton suivant en haut à droite :
    .. image:: images/19.png
       :alt: Launch
       :width: 100px

#. La formulaire de lancement va s'affichier (vérifiez que vous êtes bien en mode ``Consumer`` en haut à droite)

#. Renseignez les données suivantes :
    - ``Application name`` : **|Vos initiales]-Fiesta-Test**
    - ``Àpplication description`` : Ce que vous souhaitez
    - ``Environmant`` : Laissez **All Project Accounts**
    - ``App Profile`` : Laissez **Default**
    - ``Initiales`` : Vos initiales
    - ``AdminDB > Password`` : Le mot de passe de votre choix
  
    .. image:: images/20.png
       :alt: Launch
       :width: 350px

#. Validez avec le bouton ``Deploy`` en bas de page
    .. image:: images/37.png
       :alt: Deploy
       :width: 100px

#. Une popup va s'afficher le temps de l'initialisation du déploiement
    .. image:: images/21.png
       :alt: popup
       :width: 350px
#. Vous arrivez ensuite automatiquement sur la page de l'application qui est en cours de provisionnement
    .. image:: images/22.png
       :alt: Application
       :width: 600px
#. En cliquant sur l'onglet ``Manage``, vous allez pouvoir suivre le déploiement de l'application étapes par étapes (il faudra éventuellement cliquer sur l'oeil). 
    - Un rond bleu signifie que l'opération est en cours
    - un rond vert qu'elle est terminée avec succès
    - un rond rouge signifie qu'un problème est survenu à cette étape.
       .. image:: images/23.png
          :alt: Launch
          :width: 600px
#. Dans la zone de droite, vous avez la possibilité de cliquer sur chacune des étapes pour voir le détail des opérations, et les logs des scripts qui ont été exécutés par Calm.
    .. image:: images/24.png
       :alt: Launch
       :width: 350px
#. A la fin du déploiement (env 10mn, le moment de faire une pause café), l'application est notée ``running`` et toutes les tâches sont vertes
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
#. Sélectionnez ``Delete`` et cliquez sur la flêche à droite (Play), et confirmez.
    .. image:: images/28.png
       :alt: Delete
       :width: 200px
#. L'application va se supprimer. Attendez que ``Running`` devienne ``deleted``
    .. image:: images/29.png
       :alt: Deleted
       :width: 100px

Publication sur la Marketplace
++++++++++++++++++++++++++++++

Une fois le blueprint validé, nous allons le mettre à disposition sur la marketplace :

#. Retournez sur la liste des blueprint par le menu de gauche
    .. image:: images/30.png
       :alt: Icone blueprints
       :width: 100px

#. Cliquez sur votre blueprint **[Initiales]_Fiesta**

#. Cliquez sur ``Publish`` en haut à droite de la page d'édition
    .. image:: images/31.png
       :alt: Bouton publish
       :width: 100px

#. Renseignez les infos comme suit :
    - Nom : **[Initiales]_Fiesta**
    - Publish with secrets : **Yes**
    - Initial version : **1.0.0**
    - Description : Mettez ce que vous voulez
    - Image : Laissez vide ou ajoutez votre propre image
       .. image:: images/32.png
          :alt: Popup publish
          :width: 400px

#. Validez en cliquant sur ``Submit for approval``

Il faut aller maintenant le valider avant sa publication sur la marketplace.

#. Aller sur le Marketplace manager en cliquant sur cette icône 
    .. image:: images/33.png
       :alt: Popup publish
       :width: 40px

#. Cliquez sur l'onglet ``Approval Pending`` en haut de la page

#. Dans la liste des blueprints en cours d'attente de validation, sélectionnez votre blueprint **[Initiales]_Fiesta**

#. Dans la zone droite de la page sélectionnez les projets qui vont pouvoir accéder à ce blueprint depuis la Marketplace. Dans notre cas on ne va sélectionner que **Bootcamp**
    .. image:: images/34.png
       :alt: Popup publish
       :width: 350px

#. Validez avec 
    .. image:: images/35.png
       :alt: Popup publish
       :width: 40px

Le blueprint étant maintenant validé, il est possible de le publier, c'est à dire le rendre accessible sur la Marketplace. Nous allons le faire immédiatement

#. Aller dans l'onglet ``Approved`` 
#. Dans la zone de filtre, entrez vos **[initiales]** et validez avec 'Entrée'
#. Cliquez sur votre blueprint
#. Dans la partie droite de la page qui s'est actualisée, renseignez le commentaire de l'application, cliquez sur bouton suivant pour la publier définitivement sur la Marketplace
    .. image:: images/36.png
       :alt: Publish
       :width: 100px

.. note::
   Les commentaires sont compatibles avec le format RST (reStructured Text). Il vous est donc possible de les rendre joliment présentables pour la marketplace.

Déploiement de l'application depuis la Marketplace
++++++++++++++++++++++++++++++++++++++++++++++++++

Nous allons maintenant déployer notre application.

#. Rendez-vous sur la marketplace en cliquant sur l'icone qui se trouve tout en haut de la page sur la gauche.
#. Cliquez sur le bouton ``Get`` de la tuile correspondant à votre application
#. Vous retrouvez ici le commentaire renseigné avant sa publication définitive
#. Cliquez sur ``Launch``
#. Comme lors du lancement de test depuis l'éditeur, il vous faudra renseigner les informations suivantes :
    - ``Application name`` : **|Vos initiales]-Fiesta-Prod**
    - ``Application description`` : Ce que vous souhaitez
    - ``Environmant`` : Laissez **All Projct Accouts**
    - ``App Profile`` : Laissez **Default**
    - ``Initiales`` : Vos initiales
    - ``AdminDB > Password`` : Le mot de passe de votre choix
#. Lancez le déploiement de l'application avec 
    .. image:: images/37.png
       :alt: Deploy
       :width: 100px
#. L'application va se déployer, et vous pouvez superviser son déploiement comme nous l'avons fait lors du lancement depuis l'éditeur. Il n'est pas nécessaire d'attendre la fin pour continuer notre lab puisque nous avons testé le blueprint juste avant et que tout devrait bien se passer. 

Félicitations, vous venez de publier et de déployer votre première application Calm sur la Marketplace. 
    .. image:: images/congrats.gif
       :alt: Bravo
       :width: 500px

Nous en avons fini pour cette partie.
