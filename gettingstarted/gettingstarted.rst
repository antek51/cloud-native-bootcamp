.. _karbon_getting_started:

---------------
Environnements 
---------------

Connexion à l'environnement 
+++++++++++++++++++++++++++++++++

Pour vous connecter à l'environnement, nous utiliserons le service de **Desktop as a service** : **Nutanix Frame**

#. Depuis votre navigateur connecter vous sur l'url : https://console.nutanix.com/x/labs

#. Utiliser les identifiants suivants : 

   - Cluster 1 = user01 au user15 

      - Login : ``PHX-POC007-User[No USER]`` (01, 02, ...)
      - Password : ``nx2Tech123!``

   - Cluster 2 = user01 au user15

      - Login : ``PHX-POC024-User[No USER]``
      - Password : ``nx2Tech123!``

#. Connecter le VPN à notre réseau en utilisant le même login / password. 

   .. figure:: images/pulse.jpg

#. ça y est vous êtes parés ! 


Outils 
+++++++++++++++++

Lors de cet atelier nous utiliserons les outils suivants : 
   - putty 
   - docker 
   - kubectl 
   - k9s
   - vi (ou tout autre éditeur de texte)


Ressources 
+++++++++++++++++

Adresse Prism Central : 

- Cluster 1 = user01 au user15 

    - Login : ``admin``
    - Password : ``nx2Tech123!``

- Cluster 2 = user01 au user15

    - Login : ``admin``
    - Password : ``nx2Tech123!``



Registry privée : 
  
- Adresse IP : 
- Port utilisé : 


Plage IP pour la configuration du load balancer dans le module 4 : 

**CLUSTER 1 :** 

.. list-table:: 
   :widths: 25 75
   :header-rows: 1

   * - User ##
     - Plage IP
   * - user01
     - 10.42.7.196 - 10.42.7.197
   * - user02
     - 10.42.7.198 - 10.42.7.199
   * - user03
     - 10.42.7.200 - 10.42.7.201
   * - user04
     - 10.42.7.202 - 10.42.7.203
   * - user05
     - 10.42.7.204 - 10.42.7.205
   * - user06
     - 10.42.7.206 - 10.42.7.207
   * - user07
     - 10.42.7.208 - 10.42.7.209
   * - user08
     - 10.42.7.210 - 10.42.7.211
   * - user09
     - 10.42.7.212 - 10.42.7.213 
   * - user10
     - 10.42.7.214 - 10.42.7.215
   * - user11
     - 10.42.7.216 - 10.42.7.217
   * - user12
     - 10.42.7.218 - 10.42.7.219
   * - user13
     - 10.42.7.220 - 10.42.7.221
   * - user14
     - 10.42.7.222 - 10.42.7.223
   * - user15
     - 10.42.7.224 - 10.42.7.225


**CLUSTER 2 :**

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - User ##
     - Plage IP
   * - user01
     - 10.42.24.196 - 10.42.24.197
   * - user02
     - 10.42.24.198 - 10.42.24.199
   * - user03
     - 10.42.24.200 - 10.42.24.201
   * - user04
     - 10.42.24.202 - 10.42.24.203
   * - user05
     - 10.42.24.204 - 10.42.24.205
   * - user06
     - 10.42.24.206 - 10.42.24.207
   * - user07
     - 10.42.24.208 - 10.42.24.209
   * - user08
     - 10.42.24.210 - 10.42.24.211
   * - user09
     - 10.42.24.212 - 10.42.24.213 
   * - user10
     - 10.42.24.214 - 10.42.24.215
   * - user11
     - 10.42.24.216 - 10.42.24.217
   * - user12
     - 10.42.24.218 - 10.42.24.219
   * - user13
     - 10.42.24.220 - 10.42.24.221
   * - user14
     - 10.42.24.222 - 10.42.24.223
   * - user15 : Réservé 
     - 10.42.24.224 - 10.42.24.225