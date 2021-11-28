.. _phase5_marketplace:

---------------------------------------------------------
5. Mise à jour de l'application au sein de la marketplace
---------------------------------------------------------

Dans cette dernière partie du lab, nous allons mettre en oeuvre un blueprint pour déployer l'application Fiesta sous Calm, au format conteneurisé, comme nous l'avons fait manuellement dans les 2 partie précédentes. Puis nous le publierons sur la marketplace comme une nouvelle version de celui créé initialement dans ce bootcamp.

Création du blueprint sous Calm
+++++++++++++++++++++++++++++++

Ajout du cluster Karbon dans le projet
--------------------------------------
Avant de créer le blueprint qui va créer l'application conteneurisée, nous allons devoir ajouter notre cluster Karbon dans le projet, pour qu'on puisse l'utiliser depuis celui-ci.

Réalisons cette tâche en commençant l'ajout du Cluster Karbon au sein de Calm

#. Cliquez sur l'onglet ``Settings``

   .. image:: images/0.png
      :alt: Icone Settings
      :width: 40px

#. Allez ensuite dans l'onglet ``Accounts``
#. Cliquez sur ce bouton 

   .. image:: images/2.png
      :alt: Add account
      :width: 150px

#. Renseignez la partie droite de la page comme suit :

   - Name : **Karbon_User[Votre numéro]**
   - Provider : **Kubernetes**
   - Type : **Karbon**
   - Cluster : **User[Votre numéro]**

#. Cliquez enfin sur ``Save``
#. Puis ``Verify``

   .. image:: images/3.png
      :alt: Account verified
      :width: 150px

Associons maintenant ce cluster Karbon au projet que nous utilisons.

#. Cliquez sur l'icône ``Projects``

   .. image:: images/1.png
      :alt: Icone Projects
      :width: 40px

#. Cliquez sur ``Bootcamp``
#. Allez dans l'onglet ``Accounts``
#. Cliquez à gauche sur le bouton

   .. image:: images/4.png
      :alt: Icone Projects
      :width: 150px

#. Cliquez sur votre cluster Karbon : **Karbon_Users[Votre numéro]**

#. Sauvegardez avec Save (en haut à droite)

C'en est terminé pour cette opération

Création du blueprint
---------------------

Par manque de temps, nous allons simplement dupliquer un blueprint existant.

#. Allez dans le menu Blueprints

   .. image:: images/5.png
      :alt: Icone BP
      :width: 150px

#. Cochez la case à gauche de ``Fiesta-App_Karbon``

   .. image:: images/6.png
      :alt: Select BP
      :width: 150px

#. Puis dans le menu ``Action`` en haut, cliquez sur ``Clone``

   .. image:: images/7.png
      :alt: Clone BP
      :width: 150px

#. Nommez le clone **[Vos initiales]_Fiesta-App_Karbon** et validez avec ``Clone``

#. L'éditeur de blueprint va alors s'afficher. On y trouvera 

   - Un service ``MariaDB`` dans une VM ``MariaDB_VM``

     - Rappel : le X bleu et vert qui signifie que ca sera une VM sur Cluster Nutanix)
  
   - Un pod ``Fiesta-Pod`` qui n'utilise ici, qu'un conteneur appelé ``Fiesta_Container``

#. Cliquez sur pod ``Fiesta_Pod``

#. Dans le panneau des détails à droite, sélectionnez ``Deployment`` si ce n'est déjà fait

#. Dans le menu ``Accounts``, sélectionnez votre cluster **Karbon_User[Votre numéro]**

   .. image:: images/8.png
      :alt: Accounts
      :width: 250px

#. Sauvegardez avec ``Save`` en haut à droite de la page.

#. Si vous avez un peu de temps, vous pouvez parcourir les onglets de ce panneau des détails pour voir quelles configurations sont faites autour de Karbon.

   - N'hésitez pas à faire commuter le petit curser ``Spec Editor`` en bas. Vous verrez apparaître la configuration au format yaml. Il peut être parfois nécessaire de passer par cet éditeur pour configurer des assets non accessibles par la GUI. Par exemple, ici, on définit les variables d'environnement permettant de passer l'IP de la VM MariaDB au conteneur Fiesta.

     .. image:: images/9.png
        :alt: Spec editor
        :width: 250px

Déploiement du blueprint
------------------------

Il ne nous reste qu'a déployer notre blueprint et vérifier qu'il est fonctionnel, avant de le publier sur la Marketplace.

#. Cliquez sur ``Launch`` en haut à droite

#. Renseignez les infos habituelles :

   - Nom de l'application : **[Vos intiales]-Fiesta-Karbon-Test**
   - Vos initiales : **[Vos initiales]**


#. Lancez le déploiement avec ``Deploy``

#. Suivez le déploiement en cliquant sur l'onglet ``Manage`` puis l'action ``Create`` de l'application

#. Une fois l'application en mode ``Running``, cliquez sur l'onglet ``Services``, puis sur sur le service ``Fiesta_Pod``

#. Cliquez sur l'onglet ``Published Service``

#. Dans la partie basse, cliquez sur le lien affiché après ``App link``

   .. image:: images/10.png
      :alt: Service details
      :width: 250px

#. Dans un navigateur, consultez la page **http://[IP relevée]:5001**

#. Le site Fiesta devrait s'afficher. Si c'est le cas, le blueprint est fonctionnel.

#. Retournez sur la page Calm de votre application

#. En haut à droite, cliquez sur ``Delete`` et attendez que l'application soit supprimée.

   - Vous pouvez vous rendre dans l'onglet ``Manage`` et cliquer sur la ligne ``Delete`` pour suivre l'avancement.

Publication sur la marketplace
++++++++++++++++++++++++++++++

Publions maintenant sur la Marketplace cette nouvelle version de l'application.

#. Allez sur votre blueprint **[Vos initiales]_Fiesta-App_Karbon**

#. Cliquez sur ``Publish``, en haut à droite

#. Renseignez les infos suivants : 

   - Cliquez sur **New version of an existing Marketplace blueprint**

     .. image:: images/11.png
        :alt: replace
        :width: 250px

   - Dans le menu déroulant, sélectionnez le nom de votre application déjà publiée : **[Vos initiales]_Fiesta**
   - Activez le **Publish with Secrets**
   - Version : **2.0.0**
   - Description : Ce que vous souhaitez
  
#. Terminez avec ``Submit for approval``

#. La suite est exactement la même chose que lors de la publication intiale :

   - Allez dans le ``Marketplace Manager``
   - Cliquez sur l'onglet ``Approval Pending``
   - Cliquez sur votre blueprint
   - Ajoutez le projet **Bootcamp** dans la liste des projets qui peuvent l'utiliser
   - Validez avec l'icone **Check**
   - Dans l'onglet ``Approved``
   - Retrouvez votre blueprint et cliquez dessus (attention à la version pour retrouver le **2.0.0**)
   - A droite cliquez sur **Publish**

#. Allez dans la Marketplace, vous verrez votre application sous les 2 versions.

Vous avez terminé et bouclé la boucle : 

- Vous avez publié une application web utilisant 2 VM
- Puis vous l'avez transformée qu'une de ces VM soit remplacée par des conteneurs. Cette
- Vous avez créé un déploiement automatique de cette nouvelle application par Calm
- Pour conclure, vous avez mis à jour la Marketplace pour utiliser la nouvelles version de d'application.

.. image:: images/boss.png
   :alt: Boss
   :width: 250px