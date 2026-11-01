<?php
return [
 'adapter' => 'scholarflow-auth-web',
 'base_url' => '/auth-web',
 'identity_authority' => 'ScholarFlow Auth Store v0.3.1',
 'auth_web_reference' => 'ScholarFlow Auth Web v0.4.0',
 'default_policy' => 'deny',
 'public_routes' => ['/index.html', '/locations/', '/resources/'],
 'roles' => ['guest','reader','researcher','contributor','reviewer','editor','admin'],
 'capabilities' => [
   'reader'=>['atlas:read'], 'researcher'=>['atlas:read','collections:private'],
   'contributor'=>['atlas:read','submissions:create'],
   'reviewer'=>['atlas:read','submissions:review'],
   'editor'=>['atlas:read','content:publish'],
   'admin'=>['atlas:read','content:publish','access:manage','audit:read']
 ],
 'first_login_password_change' => true,
 'session_policy' => ['idle_minutes'=>15,'absolute_minutes'=>120],
];
