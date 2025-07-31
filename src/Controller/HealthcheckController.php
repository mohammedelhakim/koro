<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

final class HealthcheckController extends AbstractController
{
    #[Route('/healthcheck', name: 'app_healthcheck')]
    public function index(): JsonResponse
    {
        return $this->json([
            'status' => 'Running',
        ]);
    }
}
