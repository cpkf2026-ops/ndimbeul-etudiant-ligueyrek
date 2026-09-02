<?php

namespace App\Models\Concerns;

use Illuminate\Support\Str;

/**
 * Génère automatiquement un UUID v4 comme clé primaire à la création,
 * et configure Eloquent pour traiter cette clé comme une chaîne non auto-incrémentée.
 * Utilisé par tous les modèles dont la table a été créée avec $table->uuid('id')->primary().
 */
trait HasUuid
{
    public static function bootHasUuid(): void
    {
        static::creating(function ($model) {
            if (empty($model->{$model->getKeyName()})) {
                $model->{$model->getKeyName()} = (string) Str::uuid();
            }
        });
    }

    public function getIncrementing(): bool
    {
        return false;
    }

    public function getKeyType(): string
    {
        return 'string';
    }
}
