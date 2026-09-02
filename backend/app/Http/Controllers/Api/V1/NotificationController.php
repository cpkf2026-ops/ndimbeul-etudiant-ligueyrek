<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Consultation des notifications in-app (table standard `notifications`, créée par la
 * migration mais jusqu'ici jamais exposée à Flutter — corrige un manque identifié lors
 * de la vérification finale contre le CDC §8.3 "notification de l'étudiant").
 * Alimentée par App\Notifications\NouvelleOffreCorrespondante (canal 'database').
 */
class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'non_lues_seulement' => ['sometimes', 'in:0,1,true,false'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $query = $request->boolean('non_lues_seulement')
            ? $request->user()->unreadNotifications()
            : $request->user()->notifications();

        $notifications = $query->paginate($request->integer('per_page', 20));

        return response()->json([
            'data' => $notifications->items(),
            'meta' => [
                'nb_non_lues' => $request->user()->unreadNotifications()->count(),
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
            ],
        ]);
    }

    public function markAsRead(Request $request, string $id): JsonResponse
    {
        $notification = $request->user()->notifications()->findOrFail($id);
        $notification->markAsRead();

        return response()->json(['message' => 'Notification marquée comme lue.']);
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $request->user()->unreadNotifications->markAsRead();

        return response()->json(['message' => 'Toutes les notifications sont marquées comme lues.']);
    }
}
