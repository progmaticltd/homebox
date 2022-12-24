## Installation et caractéristiques du système

- Génération d'un installateur Debian personnalisé avec chiffrement complet du disque et installation entièrement
  automatique.
- Déverrouillage du système au démarrage en entrant la phrase de passe via SSH ou avec un Yubikey.
- Installation des paquets uniquement à partir de Debian stable (Bullseye).
- Génération automatique de certificats letsencrypt en utilisant le challenge DNS.
- Mises à jour de sécurité automatiques (optionnel).
- Authentification centralisée avec une base de données utilisateurs LDAP, un certificat SSL, des règles de mots de
  passe, une intégration PAM.
- AppArmor activé par défaut, avec un profil pour tous les démons.
- Mots de passe aléatoires générés et enregistrés dans le pass par défaut.
- Peut être utilisé à domicile, sur un serveur dédié ou virtuel hébergé en ligne.
- Support flexible des adresses IP : IPv4 uniquement, IPv6 uniquement, et IPv4+IPv4 ou IPv4+IPv6.
- Serveur DNS intégré, avec support CAA, DNSSEC et SSHFP (SSH fingerprint).
- Sites https de niveau A, HSTS implémenté par défaut.
- Configuration automatique du répertoire de clés Web OpenPGP.
- Règles de pare-feu automatiques pour le trafic entrant, sortant et de transfert, en utilisant nftables.
- Restriction du trafic sortant au minimum.
- Mise à jour automatique des clés DNSSEC, des serveurs DNS et des « glue records » sur Gandi.
- Ajout et suppression de composants dynamique avec Ansible


## Emails

- Configuration et installation de Postfix, avec recherche LDAP, alias email internationalisés, sécurité SSL _moderne_.
- Génération des clés DKIM, des enregistrements DNS SPF et DMARC. Les clés DKIM sont générées chaque année.
- Copie automatique des e-mails envoyés dans le dossier d'envoi (ala google mail).
- Création automatique du compte _postmaster_ et des adresses e-mail spéciales en utilisant les spécifications RFC 2142.
- Configuration de Dovecot, IMAPS, POP3S, Quotas, ManageSieve, apprentissage simple du spam et du hammer en déplaçant
  les emails dans et hors du dossier Junk, scripts sieve et vacation.
- Dossiers virtuels pour la recherche sur le serveur : messages non lus, vue des conversations, tous les messages,
  marqués et messages étiquetés comme "importants".
- Adresses électroniques avec délimiteur de destinataire inclus, par exemple john.doe+lists@dbcooper.com.
- Création facultative d'un utilisateur principal, par exemple pour les familles avec enfants ou les communautés
  modérées.
- Recherche plein texte côté serveur dans les e-mails, les documents et fichiers joints et les archives compressées,
  avec de meilleurs résultats que GMail.
- Webmail SOGo avec gestion des filtres tamis, formulaire de changement de mot de passe, gestion du calendrier et du
  carnet d'adresses, interface graphique pour importer les e-mails d'autres comptes.
- Système antispam puissant et léger avec rspamd et accès optionnel à l'interface web.
- Antivirus pour les emails entrants et sortants avec clamav.
- Configuration automatique pour Thunderbird et Outlook en utilisant le XML publié et d'autres clients avec des
  enregistrements DNS spéciaux (RFC 6186).


## Calendrier et carnet d'adresses

- Installation et configuration d'un serveur CalDAV / CardDAV, avec découverte automatique (RFC 6186).
- Fonctionnalité de groupware dans une interface web, avec SOGo.
- Événements récurrents, alertes e-mail, carnets d'adresses et calendriers partagés.
- Compatibilité avec les appareils mobiles : Android, Apple iOS, BlackBerry 10 et Windows mobile via Microsoft
  ActiveSync.


## Autres fonctionnalités optionnelles

- Sauvegardes incrémentielles, cryptées, sur plusieurs destinations (SFTP, S3, partage Samba ou clé USB), avec rapport
  par courriel et Jabber.
- Serveur Jabber, utilisant ejabberd, avec authentification LDAP, transfert de fichiers direct ou hors ligne et
  communication facultative de serveur à serveur.
- Configuration statique du squelette du site web, avec certificats https et niveau de sécurité A+ par défaut.


## Développement

- Validation des fichiers YAML à chaque commit, en utilisant travis-ci.
- Tests d'intégration de bout en bout pour la majorité des composants.
- Playbooks pour faciliter l'installation ou la suppression des paquets de développement.
- Drapeau de débogage global pour activer le mode de débogage de tous les composants.
- Scripts Ansible entièrement open source sous licence GPLv3.
