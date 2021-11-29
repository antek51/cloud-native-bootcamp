.. _phase4_container:

--------------------------------------------------------
4. Utilisation du service CaaS Nutanix Karbon
--------------------------------------------------------

Dans ce module, nous allons utiliser le service **Nutanix Karbon**. 
Ce service est **natif** dans Prism Central et compatible avec l'hyperviseur Nutanix AHV. 
Karbon est la solution de gestion des clusters Kubernetes de production de Nutanix qui permet le provisionnement clé en main, les opérations et la gestion du cycle de vie de l'ensemble des couches d'infrastructure. Contrairement aux autres solutions Kubernetes, Karbon s'intègre de manière transparente à l'ensemble de la pile cloud native de Nutanix et simplifie considérablement Kubernetes sans verrouillage. Pour les clients Nutanix, Karbon est inclus dans toutes les éditions du logiciel AOS.

Le déploiement d'un cluster Kubernetes 
**lister les add-ons d'un cluster Karbon**


Activation du service Nutanix Karbon
+++++++++++++++++++++++++++++++++++++++++++++

Pour des raisons de temps, nous avons déjà activé et mis à jour Karbon. Vous pouvez néanmoins visionner comment s'active le service grâce à l'enregistrement suivant : 

.. raw:: html 

   <iframe width="560" height="315" src="https://www.youtube.com/embed/ahzB27LQSvQ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

.. note::

   L'activation du service prend quelques minutes. En tâche de fond, l'outil déploie 2 conteneurs dans la VM Prism Central.      

   - **karbon-ui** prend en charge l'interface graphique, les requêtes API du moteur Karbon.
   - **karbon-core** est l'orchestrateur du runtime Kubernetes et tout ce qui est en relation avec la gestion des clusters.


Nous allons maintenant créer notre cluster Karbon et générer le fichier de déploiement de l'application pour l'héberger sur une base technologique de type cloud native. 

#. Dans le menu "burger" sélectionner **Services** puis **Karbon**. 

#. Vérifier que l'image **OS Images** est bien téléchargée. C'est l'image qui sera utiliser pour construire les machines virtuelles qui hébergeront le cluster Kubernetes. L'OS de ces VM est fournit par Nutanix qui en assure le maintient et la sécurisation. 

#. Créer maintenant votre cluster Kubernetes grâce au bouton **Create Kubernetes Cluster** 

   .. figure:: images/karbon1.jpg
      :alt: Boutton Create

#. Etape 1 : Selectionner un cluster de type **Development** pour des raisons simples de ressources disponibles sur la plateforme. 

   .. note::

      Un cluster de type **Development** consomme une minimum de 3 VMs : 1 Master, 1 etcd, 1 Worker.

      Un cluster de type **Production** consomme un minimum de 5 VMs : 2 Master, 3 etcs, 1 Worker. 


#. Etape 2 : Configuration générale

   - Donner un **nom** à votre cluster Kubernetes en respectant la nomenclature **user[VOTRE NUMERO]-karbon**
   - Renseigner le cluster Nutanix qui hébergera le cluster Karbon (**ne pas modifier**)
   - Renseigner la version de Kubernetes souhaitée (**Selectionner la version la plus récente**)
   - Renseigner l'image Host OS à utiliser (**Selectionner la version la plus récente**)

   .. figure:: images/karbon2.jpg
      :alt: Config cluster 

#. Etape 3 : Configuration des noeuds 

   - Nous allons installer le cluster Karbon sur le réseau **Secondary** 
   - Nous laisserons les réglages par défaut des gabarits de VMs pour les différents rôles (Worker, Master, etcd)

   .. figure:: images/karbon3.jpg
      :alt: Config node 

#. Etape 4 : Configuration du réseau interne 

   Cette étape permet de choisir le provider CNI de notre choix. Aujourd'hui Calico et Flannel sont intégrés nativement. D'autres CNI sont étudiés pour apporter d'avantage de choix pour les clients. 
      
   - Choisir entre **Flannel** ou **Calico** (cela n'a pas d'impact sur la suite sur lab)

   .. figure:: images/karbon4.jpg
      :alt: Config CNI

#. Etape 5 : Configuration de l'accès au stockage 

   - Cette dernière partie va nous permettre de gérer la configuration de la couche de stockage "bloc" dont va pouvoir bénéficier le cluster Kubernetes pour les applications nécessitant du stockage persistent. (Laisser les réglages par défaut)

   .. figure:: images/karbon5.jpg
      :alt: Config stockage

#. Pour finir cliquer sur **Create** pour lancer la création du cluster. Cela devrait prendre moins de 10 minutes. Vous pouvez monitorer l'avancement et observer l'apparition de nouvelles VMs sur le cluster Nutanix. 

   Notre cluster Kubernetes est en cours de création et sera livré avec : 

   - le CNI de votre choix configuré
   - le driver CSI permettant l'accès au stockage bloc et fichier installé 
   - Une stack de gestion des logs EFK - ElasticSearch Fluentd Kibana permettant la gestion des logs du cluster k8s lui même 
   - Une gestion du monitoring et des métriques (node exporter, metric server, prometheus)


Connexion au cluster Karbon 
+++++++++++++++++++++++++++++++++++++
#. Vérifier que le cluster Karbon ait terminé son installation. 

#. Sélectionner votre cluster Karbon dans la liste et cliquer sur **Download Kubeconfig**

#. Ouvrir le fichier **kubeconfig** et copier son contenu. 

#. Se connecter à notre docker VM **[INITIALES]-DockerVM** en ssh. 

#. Créer un dossier ``mkdir .kube``

#. Créer un fichier dans le répertoire courant ``vi .kube/config``, passer en mode insertion avec **i** et coller le contenu du kubeconfig file téléchargé. 

#. Taper **ESC** pour terminer l'édition et sauvegarde avec **:wq**.

#. Configurer la variable d'environnement avec la commande ``export KUBECONFIG=$HOME/.kube/config``

#. Tester l'accès au cluster en tapant la commande ``kubectl cluster-info``. Noter l'IP du cluster et comparer avec l'information dans Prism Central > Karbon > Votre cluster. 

#. Pour nous simplifier la vie, nous utiliserons un allias permettant de **simplifier les commandes Kubectl**. Pour cela vous pouvez taper la commande ``alias k="kubectl"``. Cela vous permet de taper ``k get pods``plutôt que ``kubectl get pods``. 



Utilisation de k9s
+++++++++++++++++++++++++

k9s est un outil permettant d'interragir simplement et rapidement avec n'importe quel cluster Kubernetes. 
Il s'agit d'un outil gratuit et développé par Fernand Galiana. Plus d'info ici : https://k9scli.io/

Il est déjà installé sur votre docker vm. 

#. Taper ``k9s`` dans le terminal pour lancer l'application. 

   .. figure:: images/k9s1.jpg


#. Tester les raccourcis clavier pour naviguer dans votre cluster kubernetes simplement. 
      - Utiliser ``:`` et les objets type **pod**, **namespace**, **services**, etc pour naviguer dans les ressources.
      - Utiliser le pavé numérique pour naviguer entre les namesspace. 


Configuration de notre cluster Karbon 
+++++++++++++++++++++++++++++++++++++++++++++++++++

Installation du load balancer : 
----------------------------------------
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

#. Les commandes suivantes vont permettre d'installer un load balancer **Metallb** automatiquement grâce à **Helm**.

   .. code-block:: bash

      helm repo add metallb https://metallb.github.io/metallb
      
      helm repo update
      
      helm install metallb metallb/metallb --set existingConfigMap=metallb
      
      k apply -f configmap-metallb.yaml

Configuration de notre registry privée : 
----------------------------------------

Notre cluster Karbon doit pouvoir accéder à notre bibliothèque d'image interne à l'entreprise. L'usage de registry public peut engendrer des problèmes de sécurité, c'est pourquoi nous allons déclarer notre registry à Karbon. 

#. Se connecter en SSH au Prism Central ``ssh nutanix@IP-PRISM-CENTRAL`` avec le mot de passe ``nutanix/4u``. 

#. La commande suivante permet de se logger sur la CLI de Karbon (Karbonctl) : ``./karbon/karbonctl login --pc-username admin --pc-password nx2Tech123! cc``

#. Ajouter la registry dans le service Karbon : ``./karbon/karbonctl registry add --name registry --url [IP-REGISTRY] --port 5000``

#. Vérifier que la registry a bien été ajoutée : ``./karbon/karbonctl registry list``

#. Ajouter la resgistry à votre cluster Karbon : ``./karbon/karbonctl cluster registry add --cluster-name [NOM-CLUSTER-KARBON] --registry-name registry``



Test avec une application simple 
+++++++++++++++++++++++++++++++++++++++++++++++++++

Nous allons vérifier le bon fonctionnement de notre load balancer en déployant une simple application. Elle devrait normalement récupérer une adresse IP et être joignable depuis l'extérieur. 

#. Créer un fichier ``vi whoami.yaml``et coller le contenu YAML ci dessous : 

   .. code-block:: yaml

      apiVersion: v1
      kind: Pod
      metadata:
      name: whoami
      namespace: app
      labels:
         app: whoami
      spec:
      containers:
         - name: whoami
            image: containous/whoami:latest
            ports:
            - containerPort: 80
      ---
      apiVersion: v1
      kind: Service
      metadata:
      name: whoami
      namespace: app
      spec:
      ports:
         - port: 80
            protocol: TCP
            targetPort: 80
      selector:
         app: whoami
      type: LoadBalancer

#. Lancer le déploiement de l'application ``kubectl create ns whoami | kubectl apply -f whoami.yaml -n whoami``

#. Vérifier la création du pod et du service dans k9s. Le service doit obtenir une IP externe du load balancer. 

   .. figure:: images/k9s2.jpg

   .. figure:: images/k9s3.jpg

#. Dans votre navigateur, se connecter sur l'ip de l'application **http://[IP-APPLICATION]**

   .. figure:: images/app1.jpg



Avant de passer à la suite, veuillez supprimer le pod ainsi que le service précédement déployé. 



Rédaction de notre fichier de déploiement de la nouvelle application Fiesta  
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Nous allons reprendre nos travaux de conteneurisation de l'application Fiesta :-) 

A la fin de la 3ième partie, nous avions une image Docker contenant l'application. L'objectif maintenant est de la déployer sur notre cluster Kubernetes et ainsi pouvoir bénéficier de ces avantages (scalabilité, résilience, cycle de développement, etc ...). 

Pour cela il faut simplement décrire la manière avec laquelle nous souhaitons exécuter l'application. Cela se réalise au travers de fichiers de description YAML. 

#. Créer le fichier ``vi fiesta-app-v2.yaml``

#. Coller le contenu suivant **en prenant soin de modifier l'adresse IP et le port de la registry, le nom de votre image de l'application Fiesta ainsi que l'IP de la VM MariaDB**. Il contient la configuration du déploiement de l'application ainsi que le service qui publie l'application à l'extérieur du cluster. 

   .. code-block:: yaml
      
      ---
      apiVersion: apps/v1
      kind: Deployment
      metadata:
      name: fiesta-app
      labels:
         app: fiesta-front
      spec:
      replicas: 1
      selector:
         matchLabels:
            app: fiesta-front
      template:
         metadata:
            labels:
            app: fiesta-front
         spec:
            containers:
            - name: fiesta-app
               image: [IP-REGISTRY]:5000/[INITIALES]-fiesta-app:latest
               ports:
                  - containerPort: 3000
               env:
               - name: MARIADB_IP
                  value: [REPRENDRE IP MARIADB]
      ---
      apiVersion: v1
      kind: Service
      metadata:
      name: fiesta-app-service
      spec:
      type: LoadBalancer
      selector:
         app: fiesta-front
      ports:
         - name: http
            protocol: TCP
            port: 5001
            targetPort: 3000
      ---
      

      
#. Suivez le déploiement de l'application dans k9s et notez l'adresse du service **fiesta-app-service**

   .. figure:: images/k9s4.jpg

#. Dans votre navigateur, se connecter sur l'ip de l'application **http://[IP-SERVICE]:5001**

   .. figure:: images/fiesta.jpg



Félicitations ! Votre application "legacy" est maintenant hébergée sur des technologies modernes sur une seule et même plateforme. 

.. figure:: images/yes.gif


.. warning::
   Avant de passer à la suite, il faut supprimer votre application Fiesta sur votre cluster Karbon car nous n'avons pas assez d'IP externe pour satisfaire les besoins de l'étape suivante. Pour cela vous pouvez utiliser ``kubectl`` ou ``k9s`` selon votre humeur.
   
   Bien penser à supprimer le deployment ainsi que le service. 